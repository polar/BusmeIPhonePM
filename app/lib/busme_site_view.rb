class BusmeSiteView < MKOverlayView

  attr_accessor :site

  def initialize(site)
    super()
    self.site = site
    self.initWithOverlay(site)
  end

  def diagonalDistance
    brect = overlay.boundingMapRect
    se = MKMapPointMake(brect.origin.x + brect.size.width,
                        brect.origin.y + brect.size.height)
    distance = MKMetersBetweenMapPoints(brect.origin, se)
  end

  def translate(r, p)
    nw = p.translatePoint(Integration::Point.new(r.origin.x, r.origin.y))
    se = p.translatePoint(Integration::Point.new(r.origin.x + r.size.width, r.origin.y + r.size.height))
    CGRectMake(nw.x, nw.y, se.x - nw.x, se.y - nw.y)
  end

  def drawMapRect(mapRect, zoomScale: zoomscale, inContext: context)
    #puts "drawMapRect - #{zoomscale} - #{printRect(mapRect)}"
    puts "ZoomScale #{zoomscale} ZoomLevel #{Math.log2(zoomscale)}"
    mpoint = MKMapPointForCoordinate(overlay.coordinate)
    cgpoint = pointForMapPoint(mpoint)
    puts "MapRect: #{printRect(overlay.boundingMapRect)}"
    p = Projection.new(self, mapRect, zoomscale)
    cgrect = rectForMapRect(overlay.boundingMapRect)
    puts "CGRect: #{printRect(cgrect)}"
    puts "TGRect: #{printRect(translate(overlay.boundingMapRect, p))}"
    CGContextSaveGState(context)
    CGContextSetLineWidth(context, 2.0/zoomscale)
    CGContextSetFillColorWithColor(context, UIColor.purpleColor.cgcolor(0.5))
    CGContextSetStrokeColorWithColor(context, UIColor.redColor.cgcolor(0.9))
    if diagonalDistance > 20*1609*2 # meters
      CGContextFillRect(context, cgrect)
      CGContextStrokeRect(context, cgrect)
    else
      dist = cgrect.size.height * zoomscale * cgrect.size.height * zoomscale + cgrect.size.width * zoomscale * cgrect.size.width * zoomscale
      radius = Math.sqrt(dist)
      mradius = [200.0, [10.0, radius].max].min
      boxwidth = mradius/zoomscale
      #puts "dist #{dist} radius #{radius} mradius #{mradius}"
      mrect = CGRectMake(cgpoint.x - boxwidth/2, cgpoint.y - boxwidth/2, boxwidth, boxwidth)
      CGContextFillEllipseInRect(context, mrect)
      CGContextStrokeEllipseInRect(context, mrect)
    end
    CGContextRestoreGState(context)
  end

  def printRect(rect)
    "RectXYHW(#{rect.origin.x}, #{rect.origin.y}, #{rect.size.height}, #{rect.size.width})"
  end

end