class MasterMapScreen < ProMotion::MapScreen
  include Platform::JourneySyncProgressEventDataConstants

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
    masterController.api.uiEvents.registerForEvent("Master:Init:return", self)
    masterController.api.uiEvents.registerForEvent("JourneySyncProgress", self)
    setMaster(masterController.master)
  end


  attr_accessor :alertView

  def showLookingDialog(master)
    self.alertView = UIAlertView.alloc.initWithTitle("Welcome to #{master.title}",
                                                message: nil,
                                                delegate:nil,
                                                cancelButtonTitle: nil,
                                                otherButtonTitles: nil)
    indicator = UIActivityIndicatorView.gray
    indicator.startAnimating
    alertView.setValue(indicator, forKey: "accessoryView")
    alertView.show
    alertView
  end

  def onProgress(eventData)
    case eventData.action
      when P_BEGIN
        alertView.message = "Contacting Server"
      when P_SYNC_START
        alertView.message = "Syncing"
      when P_SYNC_END
        alertView.message = ""
      when P_ROUTE_START
        alertView.message = "Getting #{eventData.iRoute} of #{eventData.nRoutes} Routes"
      when P_ROUTE_END
        alertView.message = "Finished #{eventData.iRoute} of #{eventData.nRoutes} Routes"
      when P_IOERROR
        alertView.message = "IOERROR!!!"
        alertView.dismissWithClickedButtonIndex(0, animated: true)
        UIAlertView.alert("Network Error", message: eventData.ioError)
      when P_DONE
        alertView.message = "DONE"
        alertView.dismissWithClickedButtonIndex(0, animated: true)
      else
    end
  end

  def doSync(forced)
    evd = Platform::JourneySyncEventData.new(isForced: forced)
    masterController.api.bgEvents.postEvent("JourneySync", evd)
    showLookingDialog(masterController.master) if forced
  end

  def onBuspassEvent(event)
    case event.eventName
      when "Master:Init:return"
        doSync(true)
      when "JourneySyncProgress"
        evd = event.eventData
        puts "JourneySyncProgress: #{evd.inspect}"
        onProgress(evd)
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