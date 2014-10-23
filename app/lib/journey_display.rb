module Platform
  # We add the boundingMapRect to the Journey Display instance
  JourneyDisplay.class_eval do
    def boundingMapRect
      return @boundingMapRect if @boundingMapRect
      nw = MKMapPointForCoordinate CLLocationCoordinate2D.new(route.nw_lat, route.nw_lon)
      se = MKMapPointForCoordinate CLLocationCoordinate2D.new(route.se_lat, route.se_lon)
      lonDelta = (nw.x - se.x).abs
      latDelta = (nw.y - se.y).abs
      @boundingMapRect = MKMapRectMake(nw.x, nw.y, lonDelta, latDelta)
    end
  end
end