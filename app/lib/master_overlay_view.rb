class JourneyDisplayView < MKOverlayView
  attr_accessor :jdOverlay

  def initialize(jdOverlay)
    super()
    self.jdOverlay = jdOverlay
    self.initWithOverlay(jdOverlay)
  end

  def drawMapRect(mapRect, zoomScale: zoomscale, inContext: context)
    cgrect = rectForMapRect(overlay.boundingMapRect)
    CGContextSaveGState(context)
    CGContextSetLineWidth(context, 2.0/zoomscale)
    CGContextSetStrokeColorWithColor(context, UIColor.blueColor.cgcolor(0.9))

  end
end