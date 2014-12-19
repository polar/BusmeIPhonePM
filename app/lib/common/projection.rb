class Projection < Utils::ScreenPathUtils::Projection
  attr_accessor :view
  attr_accessor :mapRect
  attr_accessor :zoomscale
  attr_accessor :lineWidth

  def initialize(view, mapRect, zoomscale)
    self.lineWidth = MKRoadWidthAtZoomScale(zoomscale)
    mRect = MKMapRectInset(mapRect, -lineWidth, -lineWidth)
    cgrect = view.rectForMapRect(mRect)
    # mapRect and CGRect are Lower Left Origin. We need upper left for projection rect.
    rect = Integration::Rect.new(cgrect.origin.x, cgrect.origin.y + cgrect.size.height,
                                 cgrect.origin.x + cgrect.size.width, cgrect.origin.y)
    zoomLevel = MAX_ZOOM_LEVEL + Math.log2(zoomscale)

    super(zoomLevel, rect)
    self.view = view
    self.mapRect = mRect
    self.zoomscale = zoomscale
  end

  def translatePoint(point, reuse = nil)
    if point.is_a? MKMapPoint
      p = view.pointForMapPoint(point)
    else
      mp = MKMapPointMake(point.x, point.y)
      p = view.pointForMapPoint(mp)
    end
    reuse ||= Integration::Point.new
    reuse.set(p.x, p.y)
    reuse
  end

end