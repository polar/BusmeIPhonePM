
class DiscoverScreen < ProMotion::MapScreen

  attr_accessor :api

  # initialize doesn't get called because Promotion overrides new
  def self.newScreen(args)
    puts "Initialize Discover Screen"
    api = args.delete :api
    s = self.new(args)
    s.api = api
    s
  end

  # Cannot use on_load here, because that interferes with the screen_setup.
  def on_init
    map.on_tap do
      puts "Should select"
      true
    end
    map.on_press do |args|
      puts args.locationInView(map).inspect

      cgPoint = args.locationInView(map)

      loc = map.convertPoint(cgPoint, toCoordinateFromView: map)

      puts "#{cgPoint.inspect} = #{loc.inspect}"
      mapRegion = map.region
      puts mapRegion.inspect
      puts mapRegion.span.inspect
      puts mapRegion.center.inspect
      buf = mapRegion.span.latitudeDelta / Integration::GeoPoint::LAT_PER_FOOT

      discover(DiscoverData.new(loc, buf))
      true
    end
  end

  def addMasters(masters)
    puts "Adding Masters #{masters.map {|x| x.name}.inspect}"
    sites = masters.map {|x| BusmeSite.new(x) if x.bbox}
    sites.compact!
    puts "Adding Sites #{sites.map {|x| x.master.name}}"
    time_start = Time.now
    map.addOverlays(NSArray.arrayWithArray(sites))
    end_time = Time.now
    puts "Time to Add Sites #{"%.3f sec" % (end_time - time_start)}"
  end


  def annotation_data
    []
  end

  def mapView(map_view, viewForOverlay: overlay)
    puts "View For Overlay!! #{overlay}"
    case overlay.class.name
      when "BusmeSite"
        BusmeSiteView.new(overlay)
    end
  end


end