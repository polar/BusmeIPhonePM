class MasterOverlayView < MKOverlayView
  PATTERN_DRAWING_THRESHOLD = 10

  attr_accessor :master
  attr_accessor :masterController
  attr_accessor :view
  attr_accessor :locators

  # Data for recording the mapRect at which the last locator for a JourneyDisplay was drawn.
  # We must schedule that mapRect for an update when the location changes.
  class JourneyLocationData
    attr_accessor :journeyDisplay
    attr_accessor :location
    attr_accessor :mapRect
  end

  def initialize(args)
    super()
    self.masterController = args.delete :masterController
    overlay = args.delete :overlay
    self.view = args.delete :view
    self.master = overlay.master
    self.initWithOverlay(overlay)
    @mustDrawPaths = true
    self.locators = {}
   # puts "Creating MasterOverlayView for #{master.slug}"
    registerForEvents
  end

  def registerForEvents
    masterController.api.uiEvents.registerForEvent("VisibilityChanged", self)
    masterController.api.uiEvents.registerForEvent("JourneyAdded", self)
    masterController.api.uiEvents.registerForEvent("JourneyRemoved", self)
    masterController.api.uiEvents.registerForEvent("JourneyLocationUpdate", self)
  end

  def onBuspassEvent(event)
   # puts "MasterOverlayView. Got event #{event.eventName}"
    case event.eventName
      when "JourneyAdded", "JourneyRemoved"
        journeyDisplay = event.eventData.journeyDisplay
        rect = journeyDisplay.boundingMapRect
        # Get rid of any location mapRect Data. It will get added in drawBusArrow
        self.locators.delete(journeyDisplay.route.id)
        setNeedsDisplayInMapRect(rect)
      when "JourneyLocationUpdate"
        updateJourneyLocation(event.eventData)
      when "VisibilityChanged"
        setNeedsDisplayInMapRect(overlay.boundingMapRect)
    end
   # puts "MasterOverlayView. Finished event #{event.eventName}"
  end

  # Helper function to create a MapRect with the specified mapSize
  # for a latlong coordinate.
  def mapRectForLocation(loc, mapSize)
    coord = CLLocationCoordinate2D.new(loc.latitude, loc.longitude)
    mapPoint = MKMapPointForCoordinate(coord)
    mapWidth = mapSize.width
    mapHeight = mapSize.height
    # Center the Rect
    MKMapRectMake(mapPoint.x - mapWidth/2, mapPoint.y - mapHeight/2, mapWidth, mapHeight).tap do |mapRect|
     # puts "mapRectForLocation #{loc.inspect} #{printRect mapRect}"
    end
  end

  # This method schedules a mapRect update based on the given
  # location of the journeyDisplay.
  def updateMapRect(journeyDisplay, loc)
    data = locators[journeyDisplay.route.id]
    # If data is the lastLocation we have to update that mapRect.
    # However, if it is the newLocation, we just assume the icon
    # is the same size. We assume that if the zoomLevel changes
    # that we will get a pertinent update anyway.
    if data
      size = data.mapRect.size if data.mapRect
    end
    if size.nil?
      size = journeyDisplay.boundingMapRect.size
    end
    mapRect = mapRectForLocation(loc, size)
    setNeedsDisplayInMapRect(mapRect)
  end

  # This method is the eventHandler for JourneyLocationUpdate.
  # IT signals to this view that we need to update
  # the mapRects for the old location and the new location.
  # The event comes from the journeyDisplayController.
  def updateJourneyLocation(eventData)
    journeyDisplay = eventData.journeyDisplay
    newLocation = eventData.newLocation
    oldLocation = eventData.oldLocation
    if newLocation
      updateMapRect(journeyDisplay, newLocation)
    end
    if oldLocation
      updateMapRect(journeyDisplay, oldLocation)
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
   # puts ">>>> DrawRect #{thisCount} we have #{masterController.journeyDisplayController.getJourneyDisplays.size} JourneyDisplays"
    p = Projection.new(self, mapRect, zoomscale)
    drawPaths(mapRect, p, context)
    # We draw locators over the paths.
    drawLocators(mapRect, p, context)
   # puts "<<<<< Exit DrawMapRect #{thisCount} at #{p}"
  end

  def drawPaths(mapRect, projection, context)
   # puts ">>>> DrawPaths #{p} we have #{masterController.journeyDisplayController.getJourneyDisplays.size} JourneyDisplays"
    CGContextSaveGState(context)
    CGContextSetLineWidth(context, 3.0/projection.zoomscale)
    CGContextSetStrokeColorWithColor(context, UIColor.blueColor.cgcolor(0.5))
    patterns = []
    jds = masterController.journeyDisplayController.getJourneyDisplays.dup
    jds.each do |jd|
      patterns += jd.route.journeyPatterns if jd.isPathVisible? && !jd.isPathHighlighted?
    end
    drawPatterns(patterns, projection, context)
    CGContextSetStrokeColorWithColor(context, UIColor.redColor.cgcolor(0.9))
    patterns =[]
    jds.each do |jd|
      patterns += jd.route.journeyPatterns if jd.isPathVisible? && jd.isPathHighlighted?
    end
    drawPatterns(patterns, projection, context)
    CGContextRestoreGState(context)
  end

  def printRect(rect)
    "RectXYHW(#{rect.origin.x}, #{rect.origin.y}, #{rect.size.height}, #{rect.size.width})"
  end

  def drawPatterns(patterns, projection, context)
   # puts "Should draw #{patterns.size} patterns"
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
   # puts "DrawPattern #{pattern.id} at #{projection}"
    projectedPath = pattern.projectedPath
    # Returns an Integration::Path that has a list of paths, which are arrays of Integration::Point
    path = Utils::ScreenPathUtils.toClippedScreenPath(projectedPath, projection)
    if path && path.paths
      path.paths.each do |points|
        if points.size > 1
         # puts "Path starts at #{points.first.inspect}"
          CGContextMoveToPoint(context, points.first.x, points.first.y)
          points.drop(1).each do |point|
            #puts "AddLineToPoint(#{point})"
            CGContextAddLineToPoint(context, point.x, point.y)
          end
         # puts "Path ends at #{points.last.inspect}"
        end
      end
      #puts "Stroking Path"
      CGContextStrokePath(context)
    end
  rescue Exception => boom
    PM.logger.error "Error drawing pattern"
    projectedPath.each_with_index do |p, i|
      PM.logger.error "#{i}: #{p.inspect if p}"
    end if projectedPath
  end

  def drawLocators(mapRect, projection, context)
    jds = masterController.journeyDisplayController.getJourneyDisplays.dup
    highlighted = nil
    jds.each do |jd|
      loc = jd.route.lastKnownLocation
      if loc && jd.isPathVisible?
        if ! jd.isPathHighlighted?
          drawLocator(jd, loc, mapRect, projection, context)
        else
          highlighted = jd
        end
      end
    end
    if highlighted
      loc = highlighted.route.lastKnownLocation
      if loc
        drawLocator(highlighted, loc, mapRect, projection, context)
      end
    end
  end

  def recordLocator(journeyDisplay, location, mapRect)
    data = JourneyLocationData.new
    data.journeyDisplay = journeyDisplay
    data.location = location
    data.mapRect = mapRect
    self.locators[journeyDisplay.route.id] = data
  end

  def drawLocator(jd, loc, mapRect, projection, context)
    coord = CLLocationCoordinate2D.new(loc.latitude, loc.longitude)
    mapPoint = MKMapPointForCoordinate(coord)
    cgPoint = projection.translatePoint(mapPoint)
    cgPoint = pointForMapPoint(mapPoint)
   # puts "drawLocation #{loc.inspect} #{coord.inspect} #{mapPoint.inspect} #{cgPoint.inspect}"
    if jd.isPathHighlighted?
      imageRect = drawBusArrow(jd.route, cgPoint, jd.route.lastKnownDirection, jd.route.reported, ::Locator.get("red"), projection, context)
    else
      imageRect = drawBusArrow(jd.route, cgPoint, jd.route.lastKnownDirection, jd.route.reported, ::Locator.get("blue"), projection, context)
    end
    recordLocator(jd, coord, mapRectForRect(imageRect))
  end

  # Returns the imageRect it was drawn into.
  def drawBusArrow(theRoute, point, direction, reported, locator, projection, cgContext)
   # puts "drawBusArrow at #{point.inspect} #{direction}"
    scale = [0.5, (4-(19-projection.zoomLevel)/2)/4.0].max
    icon = locator.direction(direction).scale_by(scale)
    x = point.x - icon.hotspot.x/projection.zoomscale
    y = point.y - icon.hotspot.y/projection.zoomscale
    imageRect = CGRectMake(x, y, icon.image.size.width/projection.zoomscale, icon.image.size.height/projection.zoomscale)
   # puts "drawBusArrow #{projection.zoomscale} at #{point.inspect} #{direction} into #{printRect imageRect} #{printmRect mapRectForRect(iageRect)}"
    CGContextDrawImage(cgContext, imageRect, icon.image.cgimage)
    imageRect
  end
end