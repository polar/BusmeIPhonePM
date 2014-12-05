class MasterOverlay
  attr_accessor :masterController
  attr_accessor :master
  attr_accessor :bbox

  def initialize(args)
    self.masterController = args.delete :masterController
    self.master = args.delete :master
    bs = master.bbox.map {|x| (x * 1E6).to_i} # W, N, E, S
    self.bbox = Integration::BoundingBoxE6.new(bs[1],bs[2],bs[3],bs[0]) # N, E, S, W
  end

  def coordinate
    return @centerCoord if @centerCoord
    center = bbox.getCenter
    @centerCoord = CLLocationCoordinate2D.new(center.latitude, center.longitude)
  end

  def boundingMapRect
    return @boundingMapRect if @boundingMapRect
    nw = MKMapPointForCoordinate CLLocationCoordinate2D.new(bbox.north, bbox.west)
    se = MKMapPointForCoordinate CLLocationCoordinate2D.new(bbox.south, bbox.east)
    lonDelta = (nw.x - se.x).abs
    latDelta = (nw.y - se.y).abs
    @boundingMapRect = MKMapRectMake(nw.x, nw.y, lonDelta, latDelta)
  end
end