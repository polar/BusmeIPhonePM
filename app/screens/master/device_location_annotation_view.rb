class DeviceLocationAnnotationView < MKAnnotationView

  attr_accessor :location

  def self.get(location)
    PM.logger.info "DeviceLocationAnnotationView.get #{location.inspect}"
    mv = self.alloc.initWithAnnotation(location, reuseIdentifier:"DeviceLocation")
    mv.setup
    mv
  end

  def setup
    self.image = UIImage.imageNamed("person.png")
    self.image = image.scale_to([2*image.size.width, 2*image.size.height])
    self.centerOffset = CGPoint.new(0, 0 - image.size.height/2.0)
    self.layer.shadowOpacity = 0.89
    self.layer.shadowOffset = CGSize.new(4,4)
    self
  end
end