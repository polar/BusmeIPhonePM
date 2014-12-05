class Discover1Screen < ProMotion::MapScreen
  include Orientation
  title "Busme!"

  attr_accessor :mainController
  attr_accessor :menu
  attr_accessor :routes_view
  attr_accessor :splashView

  attr_accessor :discoverInProgress

  # initialize doesn't get called because Promotion overrides new
  def self.newScreen(args)
   #puts "Initialize Discover1 Screen"
    mainController = args.delete :mainController
   #puts "Initialize Discover1 Screen #{mainController}"
    s = self.new(args)
    s.mainController = mainController
    s.splashView = SplashView.new(:imageName => args[:splash], :screen => s) if args[:splash]
    s.after_init
    s
  end

  def will_appear
    if splashView
      splashView.onView(view)
      self.splashView = nil
    end
  end

  def open?
    nav_bar? && navigation_controller.visibleViewController == self
  end

  def annotation_data
    []
  end

  def mainController=(mc)
    if mainController
      mainController.uiEvents.unregisterForEvent("Search:Discover:return", self)
      mainController.uiEvents.unregisterForEvent("Search:Find:return", self)
      mainController.release
    end
    @mainController = WeakRef.new(mc)
    mainController.uiEvents.registerForEvent("Search:Discover:return", self)
    mainController.uiEvents.registerForEvent("Search:Find:return", self)
  end

  def on_init
   #puts "SET BACK BUTTON"
    set_nav_bar_button :left, :title => "Menu", :style => :plain, :action => :open_menu
  end

  def after_init
    self.discoverInProgress = false
    initializeTouches
  end

  def initializeTouches
    map.on_tap do |args|
      performFind(args)
      true
    end
    map.on_press do |args|
      performDiscover(args)
      true
    end
  end

  def onBuspassEvent(event)
    PM.logger.info "#{self.class.name}#{__id__}:#{__method__}: event #{event.eventName}"
    case event.eventName
      when "Search:Discover:return"
        onDiscover(event)
      when "Search:Find:return"
        onFind(event)
    end
  end

  attr_accessor :errorDialogDelegate
  class ErrorDialogDelegate
    attr_accessor :screen
    attr_accessor :eventName
    attr_accessor :eventData
    def initialize(app)
      self.screen = app
      screen.errorDialogDelegate = self
    end

    def alertView(alertView, willDismissWithButtonIndex: buttonIndex)
      PM.logger.info "ErrorDialogDelegate: alertView will dismiss with #{buttonIndex}"
      screen.discoverInProgress = false
      screen.errorDialogDelegate = nil
    end

    # This method never gets called.
    def alertViewCancel(alertView)
      PM.logger.error "ErrorDialogDelegate: alertViewCancel got called!"
    end
  end

  def errorDialog(title, statusLine, delegate)
    alertView = UIAlertView.alloc.initWithTitle(title,
                                                message: statusLine.reasonPhrase,
                                                delegate: delegate,
                                                cancelButtonTitle: "OK",
                                                otherButtonTitles: nil)
    alertView.show
    alertView
  end
  def searchDialog(title, message)
    alertView = BW::UIAlertView.default(:title => title, :message => message)
    alertView.show
    alertView
  end

  def performDiscoverFromLoc(showDialog, loc, buf = nil)
    self.discoverInProgress = true
      if showDialog
        dialog = searchDialog(
            "Searching...",
            "Searching near location #{'%0.6f' % loc.longitude}, #{'%0.6f' % loc.latitude}")
      end

      if buf.nil?
        mapRegion = map.region
        buf = mapRegion.span.latitudeDelta / Integration::GeoPoint::LAT_PER_FOOT
      end

      mainController.bgEvents.postEvent("Search:discover",
                                        Platform::DiscoverEventData.new(
                                            uiData: dialog,
                                            data: {lon: loc.longitude, lat: loc.latitude, buf: buf}))
  end

  def performDiscover(args)
    PM.logger.info "#{self.class.name}#{__id__}:#{__method__}: discoverInProgress #{discoverInProgress}"
    # We need this because multiple finger clicks arrive.
    if !discoverInProgress
      self.discoverInProgress = true

      cgPoint = args.locationInView(map)

      loc = map.convertPoint(cgPoint, toCoordinateFromView: map)

      mapRegion = map.region
      buf = mapRegion.span.latitudeDelta / Integration::GeoPoint::LAT_PER_FOOT

      performDiscoverFromLoc(true, loc, buf)
    end
  end

  def onDiscover(event)
    PM.logger.info "#{self.class.name}#{__id__}:#{__method__}: discoverInProgress #{discoverInProgress}"
    evd = event.eventData
    if evd.uiData && evd.uiData.is_a?(UIAlertView)
      evd.uiData.dismissWithClickedButtonIndex(0, animated:true)
    end
    if evd.error
      boom = evd.error
      if boom.is_a? Api::HTTPError
        errorDialog("Network Error", boom.statusLine, ErrorDialogDelegate.new(self))
        # Error dialog will reset discoverInProgress
      end
    else
      masters = evd.return
      if masters
        addMasters(masters)
      end
      self.discoverInProgress = false
    end
  end

  def performFind(args)
    PM.logger.info "#{self.class.name}#{__id__}:#{__method__}: discoverInProgress #{discoverInProgress}"
    cgPoint = args.locationInView(map)
    loc = map.convertPoint(cgPoint, toCoordinateFromView: map)
    if ! discoverInProgress
      mainController.bgEvents.postEvent("Search:find",
                                        Platform::DiscoverEventData.new(data: {loc: loc}))
    end
  end

  def onFind(event)
    PM.logger.info "#{self.class.name}#{__id__}:#{__method__}: discoverInProgress #{discoverInProgress}"
    evd = event.eventData
    if evd.error
      PM.logger.error "#{self.class.name}#{__id__}:#{__method__}: Internal App Error #{evd.error}"
    else
      master = evd.return
      if master
        masterApi = IPhone::Api.new(master)
        mainController.uiEvents.postEvent("Main:Master:init",
                                          Platform::MasterEventData.new(data: {master: master, masterApi: masterApi}))
      elsif !discoverInProgress
        # Fire up a screen that will show the available masters.
        discoverController = mainController.discoverController
        if discoverController && !discoverController.masters.empty?
          loc = evd.data[:loc]
          open MastersTableScreen.newScreen(:mainController => mainController, :nav_bar => true)
        end
      end
    end
  end

  def addMasters(masters)
   #puts "Adding Masters on #{Dispatch::Queue.current} #{masters.map {|x| x.name}.inspect}"
    sites = masters.map {|x| BusmeSite.new(x) if x.bbox}
    sites.compact!
   #puts "Adding Sites #{sites.map {|x| x.master.name}}"
    time_start = Time.now
    map.addOverlays(NSArray.arrayWithArray(sites))
    end_time = Time.now
   #puts "Time to Add Sites #{"%.3f sec" % (end_time - time_start)}"
  end

  def mapView(map_view, viewForOverlay: overlay)
   #puts "View For Overlay!! #{overlay}"
    case overlay.class.name
      when "BusmeSite"
        BusmeSiteView.new(site: overlay, screen: self, view: map_view)
    end
  end

  def clear
    map.removeOverlays(map.overlays)
  end

  attr_accessor :locations
  def addLocation(loc)
   #puts "adding location"
    @locations ||= []
    @locations << loc
   #puts "adding location to view"
    self.view.addAnnotation(loc)
   #puts "added location"
  end

  def annotation_view(map_view, annotation)
   #puts "creating location view"
    LocationAnnotationView.alloc.initWithLocation(annotation)
  end

  def open_menu
   #puts "OpenMenu!!!"
    @menu ||= DiscoverMainMenu.newMenu(nav_bar: true, discoverScreen: self)
    open @menu
   #puts "Menu Opened?????"
  end

  def should_rotate(orientation)
   #puts "DiscoverScreen: should_rotate(#{interface_orientation_names[orientation]})"
   #puts "DiscoverScreen: should_rotate Interface #{interface_orientation_names[UIApplication.sharedApplication.statusBarOrientation]} superview.frame #{view.superview.inspect} bounds #{bounds.inspect}"
  end

  def will_rotate(orientation, duration)
   #puts "DiscoverScreen: will_rotate(#{interface_orientation_names[orientation]}, #{duration})"
   #puts "DiscoverScreen: will_rotate Interface #{interface_orientation_names[UIApplication.sharedApplication.statusBarOrientation]} superview.frame #{view.superview.inspect} bounds #{bounds.inspect}"
  end

  def on_rotate
    #puts "DiscoverScreen: on_rotate(#{interface_orientation_names[orientation]})"
   #puts "DiscoverScreen: on_rotate Interface #{interface_orientation_names[UIApplication.sharedApplication.statusBarOrientation]} superview.frame #{view.superview.inspect} bounds #{bounds.inspect}"
  end

  # iOS 8
  def viewWillTransitionToSize(size, withTransitionCoordinator:coordinator)
    super
   #puts "DiscoverScreen: viewWillTransitionToSize(#{size.inspect}"
   #puts "DiscoverScreen: screen #{UIScreen.mainScreen.bounds.inspect}"
   #puts "DiscoverScreen: UserInterface #{interface_orientation_names[UIApplication.sharedApplication.statusBarOrientation]} superview.frame #{view.frame.inspect} bounds #{view.bounds.inspect}"
  end

  # iOS 8
  def traitCollectionDidChange(previousTraitCollection)
    super
   #puts "DiscoverScreen: traitCollectionDidChange previous #{previousTraitCollection.inspect}"
   #puts "DiscoverScreen: traitCollectionDidChange previous vertical #{previousTraitCollection.verticalSizeClass}" if previousTraitCollection
   #puts "DiscoverScreen: traitCollectionDidChange previous horizontal #{previousTraitCollection.horizontalSizeClass}" if previousTraitCollection
   #puts "DiscoverScreen: traitCollectionDidChange current #{traitCollection.inspect}"
   #puts "DiscoverScreen: traitCollectionDidChange current vertical #{traitCollection.verticalSizeClass.inspect}"
   #puts "DiscoverScreen: traitCollectionDidChange current horizontal #{traitCollection.horizontalSizeClass.inspect}"
  end
end