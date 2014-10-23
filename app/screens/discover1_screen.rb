class Discover1Screen < ProMotion::MapScreen

  attr_accessor :mainController

  # initialize doesn't get called because Promotion overrides new
  def self.newScreen(args)
    puts "Initialize Discover1 Screen"
    mainController = args.delete :mainController
    puts "Initialize Discover1 Screen #{mainController}"
    s = self.new(args)
    s.mainController = mainController
    s.after_init
    s
  end

  def annotation_data
    []
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
    puts "performDiscover #{@discoverInProgress}"
    if !@discoverInProgress
      @discoverInProgress = true
      puts args.locationInView(map).inspect

      cgPoint = args.locationInView(map)

      loc = map.convertPoint(cgPoint, toCoordinateFromView: map)

      puts "#{cgPoint.inspect} = #{loc.inspect}"
      mapRegion = map.region
      puts mapRegion.inspect
      puts mapRegion.span.inspect
      puts mapRegion.center.inspect
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
    mainController.bgEvents.postEvent("Search:find",
                                      Platform::DiscoverEventData.new(data: {loc: loc}))
  end

  def onFind(event)
    evd = event.eventData
    master = evd.return
    if master
      masterApi = IPhone::Api.new(master)
      mainController.bgEvents.postEvent("Main:Master:init",
              Platform::MasterEventData.new(data: {master: master, masterApi: masterApi}))
    end
  end

  def addMasters(masters)
    puts "Adding Masters on #{Dispatch::Queue.current} #{masters.map {|x| x.name}.inspect}"
    sites = masters.map {|x| BusmeSite.new(x) if x.bbox}
    sites.compact!
    puts "Adding Sites #{sites.map {|x| x.master.name}}"
    time_start = Time.now
    map.addOverlays(NSArray.arrayWithArray(sites))
    end_time = Time.now
    puts "Time to Add Sites #{"%.3f sec" % (end_time - time_start)}"
  end

  def mapView(map_view, viewForOverlay: overlay)
    puts "View For Overlay!! #{overlay}"
    case overlay.class.name
      when "BusmeSite"
        BusmeSiteView.new(overlay)
    end
  end
end