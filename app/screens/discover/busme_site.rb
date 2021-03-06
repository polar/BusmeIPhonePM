class BusmeSite
  attr_accessor :master
  attr_accessor :bbox

  def initialize(master)
    self.master = master
    bs = master.bbox.map {|x| (x * 1E6).to_i} # W, N, E, S
    self.bbox = Integration::BoundingBoxE6.new(bs[1],bs[2],bs[3],bs[0]) # N, E, S, W
  end

  def myPolygon
    return @myPolygon if @myPolygon

    nw = CLLocationCoordinate2D.new(bbox.north, bbox.west)
    ne = CLLocationCoordinate2D.new(bbox.north, bbox.east)
    se = CLLocationCoordinate2D.new(bbox.south, bbox.east)
    sw = CLLocationCoordinate2D.new(bbox.south, bbox.west)
    coords = [nw,ne,se,sw]
    coordsPtr = Pointer.new(CLLocationCoordinate2D.type, coords.length)
    coords.each_index {|index| coordsPtr[index] = coords[index]}
    @myPolygon = MKPolygon.polygonWithCoordinates(coordsPtr, count: coords.length)
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

  def printRect(rect)
    "RectXYHW(#{rect.origin.x}, #{rect.origin.y}, #{rect.size.height}, #{rect.size.width})"
  end

  def intersectsMapRect(mapRect)
    #puts "IntersectsMapRect!! #{printRect mapRect}"
    MKMapRectIntersectsRect(boundingMapRect, mapRect).tap do |x|
       # puts "#{printRect boundingMapRect} X #{printRect mapRect} = #{x}"
    end
  end
end