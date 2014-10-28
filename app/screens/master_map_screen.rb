class MasterMapScreen < ProMotion::MapScreen
  include Platform::JourneySyncProgressEventDataConstants
  include Api::UpdateProgressConstants

  attr_accessor :masterController

  def self.newScreen(args)
    puts "Initialize Busme Screen"
    masterController = args.delete :masterController
    s = self.new(args)
    s.masterController = masterController
    s.after_init
    s
  end

  def annotation_data
    []
  end

  def after_init
    self.title = masterController.master.title
    masterController.api.uiEvents.registerForEvent("Master:Init:return", self)
    masterController.api.uiEvents.registerForEvent("JourneySyncProgress", self)
    masterController.api.uiEvents.registerForEvent("UpdateProgress", self)
    setMaster(masterController.master)
    initNavBarActivityItem
    initActivityDialog(masterController.master)

    map.on_tap do
      puts "Store master"
      masterController.storeMaster
    end
  end

  attr_accessor :activityIndicator

  def initNavBarActivityItem
    self.activityIndicator =  UIActivityIndicatorView.gray
    activityIndicator.hidesWhenStopped = true
    activityView = UIBarButtonItem.alloc.initWithCustomView(activityIndicator)
    set_nav_bar_button :right, button: activityView
  end

  attr_accessor :alertView

  def initActivityDialog(master)
    self.alertView = UIAlertView.alloc.initWithTitle("Welcome to #{master.title}",
                                                message: nil,
                                                delegate:nil,
                                                cancelButtonTitle: nil,
                                                otherButtonTitles: nil)
    indicator = UIActivityIndicatorView.gray
    indicator.startAnimating
    alertView.setValue(indicator, forKey: "accessoryView")
    alertView
  end

  def onSyncProgress(eventData)
    eventData.isForced = false
    case eventData.action
      when P_BEGIN
       # alertView.show if eventData.isForced
        #alertView.message = "Contacting Server"
        activityIndicator.startAnimating
      when P_SYNC_START
        puts "alertView.message : Syncing"
        #alertView.message = "Syncing"
      when P_SYNC_END
       # alertView.message = ""
      when P_ROUTE_START
        puts "alertView.message : Getting #{eventData.iRoute+1} of #{eventData.nRoutes} Routes"
        #alertView.setMessage "Getting #{eventData.iRoute+1} of #{eventData.nRoutes} Routes"
        puts "alertView.message : set"
      when P_ROUTE_END
        puts "alertView.message : Eat shit mutherfucking aapple"
       # alertView.setMessage "Eat shit mutherfucking aapple"
        puts "alertView.message : set  ^^^^^^^^^^^^^^^^^^^"
        puts "alertView.message : Finished #{eventData.iRoute+1} of #{eventData.nRoutes} Routes"
       # alertView.setMessage "Finished #{eventData.iRoute+1} of #{eventData.nRoutes} Routes"
        puts "alertView.message : set"
      when P_IOERROR
        puts "alertView.message : IOERROR"
        #alertView.message = "IOERROR!!!"
        #alertView.dismissWithClickedButtonIndex(0, animated: true)
        UIAlertView.alert("Network Error", message: eventData.ioError)
      when P_DONE
        puts "alertView.message : DONE"
       # alertView.message = "DONE"
       # alertView.dismissWithClickedButtonIndex(0, animated: true)
        activityIndicator.stopAnimating
      else
    end
    puts "Done JourneySyncProgress #{eventData.action}"
  end

  def onUpdateProgress(eventData)
    case eventData.action
      when U_START
        activityIndicator.startAnimating
      when U_FINISH
        activityIndicator.stopAnimating
    end
  end

  def doSync(forced)
    evd = Platform::JourneySyncEventData.new(isForced: forced)
    masterController.api.bgEvents.postEvent("JourneySync", evd)
  end

  def onBuspassEvent(event)
    case event.eventName
      when "Master:Init:return"
        doSync(true)
      when "JourneySyncProgress"
        evd = event.eventData
        puts "JourneySyncProgress: #{evd.action}"
        onSyncProgress(evd)
      when "UpdateProgress"
        evd = event.eventData
        puts "UpdateProgress: #{evd.action}"
        onUpdateProgress(evd)
    end
  end

  def setCenterAndZoom(master = self.master)
    bs = master.bbox.map {|x| (x * 1E6).to_i} # W, N, E, S
    bbox = Integration::BoundingBoxE6.new(bs[1],bs[2],bs[3],bs[0]) # N, E, S, W
    puts "Center master #{master.slug} on #{bbox}"
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
    puts "View For Overlay!! #{overlay}"
    case overlay.class.name
      when "MasterOverlay"
        MasterOverlayView.new(masterController: masterController, overlay: overlay, view: map_view)
    end
  end
end