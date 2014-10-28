class BusmeSiteView < MKOverlayView

  attr_accessor :site
  attr_accessor :view
  attr_accessor :screen

  def initialize(args)
    super()
    self.site = args[:site]
    self.view = args[:view]
    self.screen = args[:screen]
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
    drawSiteGraphic(mapRect, zoomScale: zoomscale, inContext: context)
  end

  def drawSiteGraphic(mapRect, zoomScale: zoomscale, inContext: context)
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

  def drawLocation(loc, mapRect, projection, context)
    coord = CLLocationCoordinate2D.new(loc.latitude, loc.longitude)
    mapPoint = MKMapPointForCoordinate(coord)
    cgPoint = projection.translatePoint(mapPoint)
    cgPoint = pointForMapPoint(mapPoint)

 end


  def drawBusArrowIcon(point, direction, reported, locator, projection, cgContext)
    imageRect = CGRectMake(0.0, 0.0, locator.image.size.width / projection.zoomscale, locator.image.size.height / projection.zoomscale)
    if true
      arrow = locator.direction(direction)
      scale = [0.5, (4-(19-projection.zoomLevel)/2)/4.0].max
      icon = arrow.scale_to([45*scale, 45*scale])
      icon
    else
      UIImage.canvas(locator.image.size) do |context|
        locator.image.draw
        # Rotate around the hotspot
        center_x = locator.image.size.width/2.0
        center_y = locator.image.size.height/2.0
        rotate = - (direction/180.0 * Math::PI)
        matrix = CGAffineTransformMakeTranslation(center_x, center_y)
        matrix = CGAffineTransformRotate(matrix, rotate)
        CGContextConcatCTM(context, matrix)
        locator.arrow.draw
        # move back
        CGContextTranslateCTM(context, center_x, center_y)

        scale = [0.5, (4-(19-projection.zoomLevel)/2)/4.0].max
        scale = 1.0
        scaleMtx = CGAffineTransformMakeScale(scale, scale)
        hotspot = [locator.hotspot.x, locator.hotspot.y]
        puts "Applying CGPoint Affine Transpform"
        hsPoint = CGPointApplyAffineTransform(CGPointMake(hotspot[0], hotspot[1]), scaleMtx)
        puts "Drawing locator inmage"
        locator.image.drawInRect(imageRect)
        #CGContextDrawImage(context, imageRect, locator.image)
        if locator.arrow
          puts "Drawing locator arrow"
          locator.arrow.drawInRect(imageRect)
          #CGContextDrawImage(context, imageRect, locator.arrow)
        end
        puts "Getting Image"
        icon = UIGraphicsGetImageFromCurrentImageContext()
        puts "Ending Context with #{icon} #{icon.CGImage}"
        UIGraphicsEndImageContext()

        x = point.x - hsPoint.x
        y = point.y - hsPoint.y
        imageRect.origin = CGPointMake(x, y)
        puts "drawing icon at #{[x, y]}"
        #icon.drawAtPoint(CGPointMake(x,y))
        #context = CGContextGetCurrentContext
        CGContextDrawImage(cgContext, imageRect, icon.CGImage)
      end
    end

    #CGContextDrawImage(cgContext, imageRect, locator.image.CGImage)
    #locView = UIImageView.alloc.initWithImage(arrow)
    #centerViewAtPoint(view, point)
    #puts "Drawing Image on #{cgContext}, at #{[point.x, point.y]} #{[arrow.size.width, arrow.size.height]}"
    #locView.frame = CGRectMake(point.x, point.y, arrow.size.width, arrow.size.height)
    #view<< locView
  end

end