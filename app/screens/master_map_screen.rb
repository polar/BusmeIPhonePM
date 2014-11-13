class TabButton < UIButton

  def routes_view=(rv)
    @routes_view = WeakRef.new(rv)
  end

  def setup
   #puts "VIEWDID LOAD     TAB BUTTON"
    setImage( UIImage.imageNamed("tab_left.png"), forState: :normal.uistate)
    setImage( UIImage.imageNamed("tab_left_pressed.png"), forState: :selected.uistate)
    self.size = [64, 61]
    self.alpha = 0
    on(:touch) do
     #puts "TAB BUTTON TOUCHED!"
      @routes_view.slide_in
    end
  end

  def slide_out
    @view_origin = origin
    animate(1.0) { self.alpha=0; self.origin = [self.origin.x + self.origin.x + self.size.width + 10, self.origin.y]}
    @view_is_out = true
  end

  def slide_in
    animate(1.0) { self.alpha=1; self.origin = @view_origin}
    @view_is_out = false
  end


end

class MasterMapScreen < ProMotion::MapScreen
  include Platform::JourneySyncProgressEventDataConstants
  include Api::UpdateProgressConstants

  attr_accessor :masterController
  attr_accessor :routes_view
  attr_accessor :tabButton
  attr_accessor :fgBannerPresentationEventController

  def self.newScreen(args)
   #puts "Initialize Busme Screen"
    masterController = args.delete :masterController
    s = self.new(args)
    s.masterController = masterController
    s.after_init
    s
  end

  def motionEnded(motion, withEvent:event)
    if (motion == UIEventSubtypeMotionShake)
     #puts "Shake detected"
      routes_view.toggle_slide
    end
  end

  def annotation_data
    []
  end

  def after_init
    self.title = masterController.master.title
    masterController.api.uiEvents.registerForEvent("Master:Init:return", self)
    masterController.api.uiEvents.registerForEvent("JourneySyncProgress", self)
    masterController.api.uiEvents.registerForEvent("UpdateProgress", self)
    masterController.api.uiEvents.registerForEvent("BannerPresent:Display", self)
    masterController.api.uiEvents.registerForEvent("BannerPresent:Dismiss", self)
    setMaster(masterController.master)
    initNavBarActivityItem
    initActivityDialog(masterController.master)

    # We need to hold a reference so it doesn't go away.
    self.fgBannerPresentationEventController = FGBannerPresentationEventController.new(masterController.api, self)


    self.routes_view = RoutesView.newView(:masterController => masterController, :masterMapScreen => self)
    view.addSubview(routes_view.view)

    tabButton = TabButton.custom
    view.addSubview(tabButton)
    tabButton.routes_view = routes_view
    routes_view.tabButton = tabButton
    routes_view.viewWillAppear(false)
    view.setAutoresizesSubviews(false)
    #routes_view.view.setAutoresizingMask UIViewAutoresizingFlexibleLeftMargin
  end

  def resizeIt
   #puts "RESIZE IT!"
    routes_view.resizeAll
  end

  attr_accessor :activityIndicator

  def initNavBarActivityItem
    self.activityIndicator =  UIActivityIndicatorView.new
    activityIndicator.hidesWhenStopped = true
    activityView = UIBarButtonItem.alloc.initWithCustomView(activityIndicator)
    set_nav_bar_button :right, button: activityView
    set_nav_bar_button :left, :title => "Menu", :style => :plain, :action => :open_menu
  end

  attr_accessor :alertView

  def initActivityDialog(master)
    self.alertView = UIAlertView.alloc.initWithTitle("Welcome to #{master.title}",
                                                message: nil,
                                                delegate:nil,
                                                cancelButtonTitle: nil,
                                                otherButtonTitles: nil)
    indicator = UIActivityIndicatorView.new
    indicator.startAnimating
    alertView.setValue(indicator, forKey: "accessoryView")
    alertView
  end

  def onSyncProgress(eventData)
    eventData.isForced = false
    case eventData.action
      when P_BEGIN
        @syncInProgress = true
       # alertView.show if eventData.isForced
        #alertView.message = "Contacting Server"
        activityIndicator.startAnimating
      when P_SYNC_START
       #puts "alertView.message : Syncing"
        #alertView.message = "Syncing"
      when P_SYNC_END
       # alertView.message = ""
      when P_ROUTE_START
       #puts "alertView.message : Getting #{eventData.iRoute+1} of #{eventData.nRoutes} Routes"
        #alertView.setMessage "Getting #{eventData.iRoute+1} of #{eventData.nRoutes} Routes"
       #puts "alertView.message : set"
      when P_ROUTE_END
       #puts "alertView.message : Eat shit mutherfucking aapple"
       # alertView.setMessage "Eat shit mutherfucking aapple"
       #puts "alertView.message : set  ^^^^^^^^^^^^^^^^^^^"
       #puts "alertView.message : Finished #{eventData.iRoute+1} of #{eventData.nRoutes} Routes"
       # alertView.setMessage "Finished #{eventData.iRoute+1} of #{eventData.nRoutes} Routes"
       #puts "alertView.message : set"
      when P_IOERROR
       #puts "alertView.message : IOERROR"
        #alertView.message = "IOERROR!!!"
        #alertView.dismissWithClickedButtonIndex(0, animated: true)
        UIAlertView.alert("Network Error", message: eventData.ioError)
      when P_DONE
       #puts "alertView.message : DONE"
       # alertView.message = "DONE"
       # alertView.dismissWithClickedButtonIndex(0, animated: true)
        @syncInProgress = false
        activityIndicator.stopAnimating if !@syncInProgress && !@updateInProgress
      else
    end
   #puts "Done JourneySyncProgress #{eventData.action}"
  end

  def onUpdateProgress(eventData)
    case eventData.action
      when U_START
        @updateInProgress = true
        activityIndicator.startAnimating
      when U_FINISH
        @updateInProgress = false
        activityIndicator.stopAnimating if !@syncInProgress && !@updateInProgress
    end
  end

  def doSync(forced)
    evd = Platform::JourneySyncEventData.new(isForced: forced)
    masterController.api.bgEvents.postEvent("JourneySync", evd)
  end

  def didReceiveMemoryWarning
    puts "***************************  MAPSCREEN: MEMORY WARNING **********************************"
  end

  def onBuspassEvent(event)
   #puts "MasterMapScreen: onBuspassEvent(#{event.eventName})"
   #puts "MasterMapScreen: onBupassEvent make Array #{[]}"
    case event.eventName
      when "Master:Init:return"
        doSync(true)
      when "JourneySyncProgress"
        evd = event.eventData
       #puts "JourneySyncProgress: #{evd.action}"
        onSyncProgress(evd)
      when "UpdateProgress"
        evd = event.eventData
       #puts "UpdateProgress: #{evd.action}"
        onUpdateProgress(evd)
    end
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

end