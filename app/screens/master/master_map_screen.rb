
class MasterMapScreen < ProMotion::MapScreen
  include Platform::JourneySyncProgressEventDataConstants
  include Api::UpdateProgressConstants

  attr_accessor :masterController
  attr_accessor :routesView
  attr_accessor :tabButton
  attr_accessor :fgBannerPresentationEventController
  attr_accessor :fgMarkerPresentationEventController
  attr_accessor :fgMasterMessagePresentationEventController
  attr_accessor :fgLoginController
  attr_accessor :fgJourneyEventController

  attr_accessor :journeySelectionScreen

  attr_accessor :splashView

  title "Busme!"

  def open?
    nav_bar? && navigation_controller.visibleViewController == self
  end

  def self.newScreen(args)
    s = self.new(args)
    s.splashView = SplashView.new(:imageName => args[:splash], :screen => s) if args[:splash]
    s.after_init
    s
  end

  def after_init
    initializeTouches
  end

  def initializeTouches
    map.on_tap do |args|
      PM.logger.info "#{self.class.name}:on_tap #{args.inspect}"
      true
    end
    map.on_tap(taps: 2, fingers: 2) do |args|
      PM.logger.info "#{self.class.name}:on_tap(2,2) #{args.inspect}"
      move_to_user_location
      true
    end
    map.on_press do |args|
      PM.logger.info "#{self.class.name}:on_press #{args.inspect}"
      true
    end
  end

  def will_appear
    if splashView
      splashView.onView(view)
      self.splashView = nil
    end
  end

  def motionEnded(motion, withEvent:event)
    if (motion == UIEventSubtypeMotionShake)
     #puts "Shake detected"
      routesView.toggle_slide
    end
  end

  ##
  # We nullify this effect as we are managing our own annotations without ProMotion::MapScreen
  #
  def update_annotation_data

  end

  def annotation_data
    []
  end

  attr_accessor :deviceLocationAnnotation
  attr_accessor :tabButton

  def initWithMasterController(masterController)
    self.masterController = masterController
    PM.logger.warn "MasterMapScreen:after_init: #{masterController.master.to_s}"
    self.title = masterController.master.title
    masterController.api.uiEvents.registerForEvent("Master:Init:return", self)
    masterController.api.uiEvents.registerForEvent("JourneySyncProgress", self)
    masterController.api.uiEvents.registerForEvent("UpdateProgress", self)
    masterController.api.uiEvents.registerForEvent("BannerPresent:Display", self)
    masterController.api.uiEvents.registerForEvent("BannerPresent:Dismiss", self)
    masterController.api.uiEvents.registerForEvent("LocationUpdate", self)
    masterController.api.uiEvents.registerForEvent("LoginEvent", self)
    setMaster(masterController.master)
    initNavBarActivityItem
    initSyncDialog(masterController.master)
    # We just start it because it will be a forced Sync anyway.
    syncDialog.show

    # We need to hold a reference so it doesn't go away.
    self.fgBannerPresentationEventController = FGBannerPresentationEventController.new(masterController.api, self)
    self.fgMarkerPresentationEventController = FGMarkerPresentationEventController.new(masterController.api, self)
    self.fgMasterMessagePresentationEventController = FGMasterMessagePresentationEventController.new(masterController.api, self)
    self.fgLoginController = LoginForeground.new(masterController.api, self)
    self.fgJourneyEventController = FGJourneyEventController.new(masterController.api, self)

    if self.routesView
      routesView.view.removeFromSuperview
    end
    if self.tabButton
      tabButton.removeFromSuperview
    end
    self.routesView = RoutesView.newView(:masterController => masterController, :masterMapScreen => self)
    view.addSubview(routesView.view)

    self.tabButton = TabButton.custom
    view.addSubview(tabButton)
    tabButton.routesView = routesView
    routesView.tabButton = tabButton
    routesView.viewWillAppear(false)
    view.setAutoresizesSubviews(false)
    #routes_view.view.setAutoresizingMask UIViewAutoresizingFlexibleLeftMargin
  end

  def setCenterAndZoom(master = self.master)
    bs = master.bbox.map {|x| (x * 1E6).to_i} # W, N, E, S
    bbox = Integration::BoundingBoxE6.new(bs[1],bs[2],bs[3],bs[0]) # N, E, S, W
    #puts "Center master #{master.slug} on #{bbox}"
    center = bbox.getCenter
    # TODO: Expand Just a bit so that the ends aren't at the edge of the screen
    centerCoord = CLLocationCoordinate2D.new(center.latitude, center.longitude)
    span = MKCoordinateSpanMake(bbox.north - bbox.south, bbox.east - bbox.west)
    region = MKCoordinateRegionMake(centerCoord, span)
    map.setRegion(region, animated: true)
  end

  def setMaster(master)
    overlay = MasterOverlay.new(masterController: masterController, master: master)
    map.addOverlay(overlay)
    setCenterAndZoom(master)
  end

  def move_to_user_location
    loc = user_location || (deviceLocationAnnotation && deviceLocationAnnotation.location)
    if loc
      self.center = { :longitude => loc.longitude, :latitude => loc.latitude, :animated => true}
    end
  end

  def resizeIt
   #puts "RESIZE IT!"
    routesView.resizeAll
  end

  attr_accessor :activityIndicator

  def initNavBarActivityItem
    self.activityIndicator =  UIActivityIndicatorView.new
    activityIndicator.hidesWhenStopped = true
    activityView = UIBarButtonItem.alloc.initWithCustomView(activityIndicator)
    set_nav_bar_button :right, button: activityView
    set_nav_bar_button :left, :title => "Menu", :style => :plain, :action => :open_menu
  end

  attr_accessor :syncDialog

  def initSyncDialog(master)
    self.syncDialog = UIAlertView.alloc.initWithTitle("Welcome to #{master.title}",
                                                message: nil,
                                                delegate:nil,
                                                cancelButtonTitle: nil,
                                                otherButtonTitles: nil)
    indicator = UIActivityIndicatorView.new
    indicator.startAnimating
    syncDialog.setValue(indicator, forKey: "accessoryView")
    syncDialog
  end

  def onSyncProgress(eventData)
    case eventData.action
      when P_BEGIN
        @syncInProgress = true
        syncDialog.show if eventData.isForced
        syncDialog.message = "Contacting Server"
        activityIndicator.startAnimating
      when P_SYNC_START
        syncDialog.message = "Server Contacted"
      when P_SYNC_END
       # alertView.message = ""
      when P_ROUTE_START
        syncDialog.setMessage "Getting #{eventData.iRoute+1} of #{eventData.nRoutes} Routes"
      when P_ROUTE_END
       syncDialog.setMessage "Finished #{eventData.iRoute+1} of #{eventData.nRoutes} Routes"
      when P_IOERROR
       syncDialog.message = "Network Error"
       syncDialog.dismissWithClickedButtonIndex(0, animated: true)
       UIAlertView.alert("Network Error", message: eventData.ioError)
      when P_DONE
       syncDialog.message = "Got #{eventData.nRoutes} Routes"
       syncDialog.dismissWithClickedButtonIndex(0, animated: true)
       @syncInProgress = false
       activityIndicator.stopAnimating if !@syncInProgress && !@updateInProgress
       routesView.update_table_data
      else
    end
  end

  def onUpdateProgress(eventData)
    case eventData.action
      when U_START
        @updateInProgress = true
        activityIndicator.startAnimating
      when U_FINISH
        @updateInProgress = false
        activityIndicator.stopAnimating if !@syncInProgress && !@updateInProgress
        routesView.update_table_data
    end
  end

  def doSync(forced)
    evd = Platform::JourneySyncEventData.new(isForced: forced)
    masterController.api.bgEvents.postEvent("JourneySync", evd)
  end

  def didReceiveMemoryWarning
    PM.logger.error "***************************  MAPSCREEN: MEMORY WARNING **********************************"
  end

  def onBuspassEvent(event)
   #puts "MasterMapScreen: onBuspassEvent(#{event.eventName})"
   #puts "MasterMapScreen: onBupassEvent make Array #{[]}"
    evd = event.eventData
    case event.eventName
      when "Master:Init:return"
        onMasterInitReturn(evd)
      when "JourneySyncProgress"
        onSyncProgress(evd)
      when "UpdateProgress"
        onUpdateProgress(evd)
      when "LocationUpdate"
        onLocationUpdate(evd)
      when "LoginEvent"
        onLogin(evd)
    end
  end

  def onMasterInitReturn(evd)
    if evd.error
      PM.logger.error "#{self.class.name}:#{__method__}: error #{evd.error}"
    else
      force = evd.data[:disposition] != :default
      doSync(force)
    end
  end

  def mapView(map_view, viewForOverlay: overlay)
   #puts "View For Overlay!! #{overlay}"
    case overlay.class.name
      when "MasterOverlay"
        MasterOverlayView.new(masterController: masterController, overlay: overlay, view: map_view)
    end
  end

  def open_menu
    open MasterMainMenu.newMenu(nav_bar: true,
                                mainController: masterController.mainController,
                                masterController: masterController,
                                masterMapScreen: self)
  end

  def mapView(map_view, viewForAnnotation: annotation)
    PM.logger.info "MasterMapScreen mapvView viewfor Annotation #{annotation.type}"
    case annotation.type
      when "MarkerAnnotation"
        MarkerAnnotationView.get(annotation, self)
      when "DeviceLocationAnnotation"
        DeviceLocationAnnotationView.get(annotation)
    end
  end

  def addMarker(marker)
    PM.logger.info "MasterMapScreen addMarker #{marker}"
    add_annotation(marker)
  end

  def removeMarker(marker)
    @promotion_annotation_data.each do |annotation|
      if annotation.is_a?(MarkerAnnotation) && annotation.markerInfo.id = marker.id
        self.view.removeAnnotation(annotation)
      end
    end
  end

  def add_annotation(annotation)
    PM.logger.warn "#{self.class.name}:#{__method__}: #{annotation.inspect}"
    if annotation.is_a?(Api::MarkerInfo)
      @promotion_annotation_data << MarkerAnnotation.new(annotation)
      self.view.addAnnotation @promotion_annotation_data.last
    elsif annotation.is_a?(DeviceLocationAnnotation)
      @promotion_annotation_data << annotation
      self.view.addAnnotation @promotion_annotation_data.last
    end
  end

  def add_annotations(annotations)

  end

  def onLocationUpdate(eventData)
    loc = eventData.location
    PM.logger.warn "Got a Location Update #{loc.inspect} annotations #{self.view.annotations.inspect}"
    if self.deviceLocationAnnotation
      self.deviceLocationAnnotation.location = loc
    else
      PM.logger.warn "Creating DeviceLocationAnnotation #{loc.inspect}"
      self.deviceLocationAnnotation = DeviceLocationAnnotation.new(loc)
      self.add_annotation(deviceLocationAnnotation)
    end
  end

  ##
  # This call is basically when a login spawned by the reporting screen.
  # This is the continuation.
  def onLogin(eventData)
    PM.logger.info "#{self.class.name}:#{__method__} eventData #{eventData}"
    if eventData.loginManager.is_a?(ReportingLoginManager)
      if eventData.loginManager.login.loginState == Api::Login::LS_LOGGED_IN
        eventData.loginManager.onScreen(self)
      end
    elsif eventData.loginManager.is_a?(LoginManager)
      case eventData.loginManager.login.loginState
        when Api::Login::LS_LOGGED_IN, Api::Login::LS_LOGGED_OUT
          eventData.loginManager.close_up
      end
    end
  end
end