class Discover1Screen < ProMotion::MapScreen
  include Orientation
  title "Busme!"

  attr_accessor :mainController
  attr_accessor :menu
  attr_accessor :routes_view

  # initialize doesn't get called because Promotion overrides new
  def self.newScreen(args)
   #puts "Initialize Discover1 Screen"
    mainController = args.delete :mainController
   #puts "Initialize Discover1 Screen #{mainController}"
    s = self.new(args)
    s.mainController = mainController
    s.after_init
    s
  end

  def annotation_data
    []
  end

  def mainController=(mc)
    @mainController = WeakRef.new(mc)
  end

  def on_init
   #puts "SET BACK BUTTON"
    set_nav_bar_button :left, :title => "Menu", :style => :plain, :action => :open_menu
  end

  def after_init
    mainController.uiEvents.registerForEvent("Search:Init:return", self)
    mainController.uiEvents.registerForEvent("Search:Discover:return", self)
    mainController.uiEvents.registerForEvent("Search:Find:return", self)
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
    case event.eventName
      when "Search:Discover:return"
        onDiscover(event)
      when "Search:Find:return"
        onFind(event)
    end
  end

  def performDiscover(args)
   #puts "performDiscover #{@discoverInProgress}"
    if !@discoverInProgress
      @discoverInProgress = true
     #puts args.locationInView(map).inspect

      cgPoint = args.locationInView(map)

      loc = map.convertPoint(cgPoint, toCoordinateFromView: map)

     #puts "#{cgPoint.inspect} = #{loc.inspect}"
      mapRegion = map.region
     #puts mapRegion.inspect
     #puts mapRegion.span.inspect
     #puts mapRegion.center.inspect
      buf = mapRegion.span.latitudeDelta / Integration::GeoPoint::LAT_PER_FOOT

      mainController.bgEvents.postEvent("Search:discover",
          Platform::DiscoverEventData.new(data: {lon: loc.longitude, lat: loc.latitude, buf: buf}))
    end
  end

  def onDiscover(event)
    evd = event.eventData
    masters = evd.return
    if masters
      addMasters(masters)
    end
    @discoverInProgress = false
  end

  def performFind(args)
    cgPoint = args.locationInView(map)
    loc = map.convertPoint(cgPoint, toCoordinateFromView: map)
    if ! @discoverInProgress
      mainController.bgEvents.postEvent("Search:find",
                                      Platform::DiscoverEventData.new(data: {loc: loc}))
    end
  end

  def onFind(event)
    evd = event.eventData
    master = evd.return
    if master
      masterApi = IPhone::Api.new(master)
      mainController.bgEvents.postEvent("Main:Master:init",
              Platform::MasterEventData.new(data: {master: master, masterApi: masterApi}))
    elsif !@discoverInProgress
      # Fire up a screen that will show the available masters.
      discoverController = mainController.discoverController
      if discoverController && !discoverController.masters.empty?
        loc = evd.data[:loc]
        open MastersTableScreen.newScreen(:mainController => mainController, :nav_bar => true)
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