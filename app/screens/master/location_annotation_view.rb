class LocationAnnotationView < MKAnnotationView

  attr_accessor :location

  def initWithLocation(location)
    initWithAnnotation(location, reuseIdentifier: location.identifier)
    self.location = location
    self.update()
    location.view = self
    #self.frame(CGRect.new([0,0],[45,45]))
    self
  end

  def update()
    locator = Locator.get("red")
    icon1 = locator.direction(location.direction)
    icon = icon1.scale_to(CGSize.new(23,23))
    self.image = icon.image
    self.centerOffset = icon.hotspot
    self.setNeedsDisplay
  end
end