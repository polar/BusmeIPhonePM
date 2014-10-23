Utils::ScreenPathUtils.class_eval do

  def self.latLongToPixelXY(latitude, longitude, levelOfDetail, reuse = nil)
    out = reuse.nil? ? Integration::Point.new : reuse

    nw = MKMapPointForCoordinate CLLocationCoordinate2D.new(latitude, longitude)
    out.set(nw.x, nw.y)
    out
  end

  def self.toClippedScreenPath(projectedPath, projection)

    puts "IPhone:toClippedScreenPath(#{projectedPath.length} points) on #{projection}"
    rect = projection.screenRect
    path = Integration::Path.new
    coords = Integration::Point.new
    for point in projectedPath
      projection.translatePoint(point, coords)
      # The iPhone, this is actually faster.
      path.lineTo(coords.x,coords.y)
    end
    path
  end
end