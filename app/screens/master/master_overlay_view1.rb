class MasterOverlayView1 < MKOverlayView
  PATTERN_DRAWING_THRESHOLD = 10

  attr_accessor :master
  attr_accessor :masterController
  attr_accessor :mapLayer
  attr_accessor :view

  attr_accessor :patterns
  attr_accessor :locators
  attr_accessor :previousLocators

  class MyMapLayer < Platform::RoutesAndLocationsMapLayer
    attr_accessor :delegate
    def initialize(jd, journeyDisplayController, delegate)
      super(jd,journeyDisplayController)
      self.delegate = delegate
    end

    def placePattern(pattern, disposition, context)
      self.delegate.placePattern(pattern, disposition, context)
    end

    ##
    # Places a directional locator on the map at location according to direction and
    # a visual for disposition and reported. It may also place text on the screen as well
    # in conjunction with the locator.
    #
    def placeJourneyLocator(journeyDisplay, location, direction, reported, disposition, context)
      self.delegate.placeJourneyLocator(journeyDisplay, location, direction, reported, disposition, context)
    end
  end

  def initialize(args)
    super()
    self.masterController = args.delete :masterController
    overlay = args.delete :overlay
    self.view = args.delete :view
    self.master = overlay.master
    self.initWithOverlay(overlay)
    self.mapLayer = MyMapLayer.new(masterController.api, masterController.journeyVisibilityController, self)
    @mustDrawPaths = true
    self.locators = []
    self.patterns = []
    self.previousLocators = {}
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
        reset
        setNeedsDisplayInMapRect(rect)
      when "JourneyLocationUpdate"
        reset
      when "VisibilityChanged"
        reset
        setNeedsDisplayInMapRect(overlay.boundingMapRect)
    end
    # puts "MasterOverlayView. Finished event #{event.eventName}"
  end

  ##
  # This function can be extended in Android to transform the pattern
  # into a path at the current projection and draw it, or place it as a MKPolyline
  # in iOS.
  class PatternView
    attr_accessor :pattern
    attr_accessor :disposition
    attr_accessor :color
    def initialize(p,d)
      self.pattern = p
      self.disposition = d
      case disposition
        when Platform::Disposition::HIGHLIGHT
          self.color = UIColor.redColor.cgcolor(0.5)
        when Platform::Disposition::TRACK
          self.color = UIColor.greenColor.cgcolor(0.75)
        else
          self.color = UIColor.blueColor.cgcolor(0.5)
      end
    end
  end

  class LocatorView
    attr_accessor :journeyDisplay
    attr_accessor :location
    attr_accessor :direction
    attr_accessor :reported
    attr_accessor :disposition
    attr_accessor :icon
    attr_accessor :mapRect
    def initialize(jd,l,dir,r,disp)
      self.journeyDisplay = jd
      self.location = l
      self.direction = dir
      self.reported = r
      self.disposition = disp
      case disposition
        when Platform::Disposition::HIGHLIGHT
          self.icon = ::Locator.new("red", reported).direction(direction)
        when Platform::Disposition::TRACK
          self.icon = ::Locator.new("green", reported).direction(direction)
        else
          self.icon = ::Locator.new("blue", reported).direction(direction)
      end
    end
  end

  def reset
    self.patterns = []
    self.locators = []
    mapLayer.place(nil)
  end

  def placePattern(pattern, disposition, context)
    self.patterns << PatternView.new(pattern,disposition)
  end

  ##
  # Places a directional locator on the map at location according to direction and
  # a visual for disposition and reported. It may also place text on the screen as well
  # in conjunction with the locator.
  #
  def placeJourneyLocator(journeyDisplay, location, direction, reported, disposition, context)
    self.locators << LocatorView.new(journeyDisplay, location, direction, reported, disposition)
  end

  def drawMapRect(mapRect, zoomScale: zoomscale, inContext: context)
    @count ||= 0
    thisCount = (@count += 1)
    # puts ">>>> DrawRect #{thisCount} we have #{masterController.journeyDisplayController.getJourneyDisplays.size} JourneyDisplays"
    p = Projection.new(self, mapRect, zoomscale)
    drawPatterns(p, context)
    # We draw locators over the paths.
    drawLocators(p, context)
    # puts "<<<<< Exit DrawMapRect #{thisCount} at #{p}"
  end

  def drawPatterns(projection, context)
    # puts "Should draw #{patterns.size} patterns"
    lastNumberOfPathsVisible = 0
    drawn = {}
    patterns.each do |p|
      if p.pattern.isReady?
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

  def drawLocators(projection, context)
    locators.each do |l|
      drawLocator(l, projection, context)
    end
  end

  def drawPattern(patternView, projection, context)
    CGContextSaveGState(context)
    CGContextSetLineWidth(context, 3.0/projection.zoomscale)
    CGContextSetStrokeColorWithColor(context, patternView.color)

    # puts "DrawPattern #{pattern.id} at #{projection}"
    projectedPath = patternView.pattern.projectedPath
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
  ensure
    CGContextRestoreGState(context)
  end

  def drawLocator(locatorView, projection, context)
    loc = locatorView.location
    coord = CLLocationCoordinate2D.new(loc.latitude, loc.longitude)
    mapPoint = MKMapPointForCoordinate(coord)
    cgPoint = pointForMapPoint(mapPoint)
    jd = locatorView.journeyDisplay
    imageRect = drawBusArrow(cgPoint,
                             locatorView.locator,
                             projection,
                             context)
    recordLocator(jd, coord, mapRectForRect(imageRect))
  end

  # Returns the imageRect it was drawn into.
  def drawBusArrow(point, locator, projection, cgContext)
    # puts "drawBusArrow at #{point.inspect} #{direction}"
    scale = [0.5, (4-(19-projection.zoomLevel)/2)/4.0].max
    icon = locator.scale_by(scale)
    x = point.x - icon.hotspot.x/projection.zoomscale
    y = point.y - icon.hotspot.y/projection.zoomscale
    imageRect = CGRectMake(x, y, icon.image.size.width/projection.zoomscale, icon.image.size.height/projection.zoomscale)
    # puts "drawBusArrow #{projection.zoomscale} at #{point.inspect} #{direction} into #{printRect imageRect} #{printmRect mapRectForRect(iageRect)}"
    CGContextDrawImage(cgContext, imageRect, icon.image.cgimage)
    imageRect
  end

  def recordLocator(journeyDisplay, locator, mapRect)
    locator.mapRect = mapRect
    self.previousLocator[journeyDisplay.route.id] = locator
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
    data = previousLocators[journeyDisplay.route.id]
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

end