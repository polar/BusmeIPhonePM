Utils::ScreenPathUtils.class_eval do

  def self.latLongToPixelXY(latitude, longitude, levelOfDetail, reuse = nil)
    out = reuse.nil? ? Integration::Point.new : reuse

    nw = MKMapPointForCoordinate CLLocationCoordinate2D.new(latitude, longitude)
    out.set(nw.x, nw.y)
    out
  end

  def self.toClippedScreenPath(projectedPath, projection)

    #puts "IPhone:toClippedScreenPath(#{projectedPath.length} points) on #{projection}"
    rect = projection.screenRect
    path = Integration::Path.new
    coords = Integration::Point.new
    for point in projectedPath
      if point
        projection.translatePoint(point, coords)
        # For the iPhone, just placing the point on the path is actually faster than deciding
        # whether it is in the MapRect of the projection to
        # draw the line. See the Android code for example.
        path.lineTo(coords.x,coords.y)
      else
        PM.logger.error "A point in projectedPath is nil"
      end
    end
    path
  end
end