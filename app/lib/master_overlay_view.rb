class MasterOverlayView < MKOverlayView
  PATTERN_DRAWING_THRESHOLD = 10

  attr_accessor :master
  attr_accessor :masterController
  attr_accessor :view

  def initialize(args)
    super()
    self.masterController = args.delete :masterController
    overlay = args.delete :overlay
    self.view = args.delete :view
    self.master = overlay.master
    self.initWithOverlay(overlay)
    @mustDrawPaths = true
    puts "Creating MasterOverlayView for #{master.slug}"
    registerForEvents
  end

  def registerForEvents
    masterController.api.uiEvents.registerForEvent("JourneyAdded", self)
    masterController.api.uiEvents.registerForEvent("JourneyRemoved", self)
  end

  def onBuspassEvent(event)
    case event.eventName
      when "JourneyAdded", "JourneyRemoved"
        journeyDisplay = event.eventData.journeyDisplay
        rect = journeyDisplay.boundingMapRect
        setNeedsDisplayInMapRect(rect)
    end
  end

  # Map Rects and CGRects are Lower Left Orientation
  def translate(m, p)
    sw = p.translatePoint(m.origin)
    ne = p.translatePoint(Integration::Point.new(m.origin.x + m.size.width, m.origin.y + m.size.height))
    CGRectMake(sw.x, sw.y, ne.x - sw.x, ne.y - sw.y)
  end

  def drawMapRect(mapRect, zoomScale: zoomscale, inContext: context)
    @count ||= 0
    thisCount = (@count += 1)
    puts ">>>> DrawRect #{thisCount} we have #{masterController.journeyDisplayController.getJourneyDisplays.size} JourneyDisplays"
    drawPaths(mapRect, zoomscale, context)
    puts "<<<<< Exit DrawMapRect #{thisCount} at #{p}"
  end

  def drawPaths(mapRect, zoomscale, context)
    p = Projection.new(self, mapRect, zoomscale)
    puts ">>>> DrawPaths #{p} we have #{masterController.journeyDisplayController.getJourneyDisplays.size} JourneyDisplays"
    CGContextSaveGState(context)
    CGContextSetLineWidth(context, 3.0/zoomscale)
    CGContextSetStrokeColorWithColor(context, UIColor.blueColor.cgcolor(0.5))
    patterns = []
    jds = masterController.journeyDisplayController.getJourneyDisplays.dup
    jds.each do |jd|
      patterns += jd.route.journeyPatterns if jd.isPathVisible?
    end
    drawPatterns(patterns, p, context)
    CGContextRestoreGState(context)
  end

  def printRect(rect)
    "RectXYHW(#{rect.origin.x}, #{rect.origin.y}, #{rect.size.height}, #{rect.size.width})"
  end


  def drawPatterns(patterns, projection, context)
    puts "Should draw #{patterns.size} patterns"
    lastNumberOfPathsVisible = 0
    drawn = {}
    patterns.each do |p|
      if p.isReady?
        if @mustDrawPaths || lastNumberOfPathsVisible < PATTERN_DRAWING_THRESHOLD
          if drawn[p].nil?
            drawPattern(p, projection, context)
            drawn[p] = true
            lastNumberOfPathsVisible += 1
          end
        else
          break
        end
      end
    end
  end

  def drawPattern(pattern, projection, context)
    puts "DrawPattern #{pattern.id} at #{projection}"
    projectedPath = pattern.projectedPath
    # Returns an Integration::Path that has a list of paths, which are arrays of Integration::Point
    path = Utils::ScreenPathUtils.toClippedScreenPath(projectedPath, projection)
    if path && path.paths
      path.paths.each do |points|
        if points.size > 1
          CGContextMoveToPoint(context, points.first.x, points.first.y)
          points.drop(1).each do |point|
            #puts "AddLineToPoint(#{point})"
            CGContextAddLineToPoint(context, point.x, point.y)
          end
        end
      end
      #puts "Stroking Path"
      CGContextStrokePath(context)
    end
  end
end