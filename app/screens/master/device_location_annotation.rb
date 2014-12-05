class DeviceLocationAnnotation < MKPointAnnotation

  attr_reader :location
  attr_accessor :type

  def initialize(location)
    self.location = location
    self.type = self.class.name
  end

  def location=(coord)
    @location = coord
    self.setCoordinate CLLocationCoordinate2DMake(coord.latitude, coord.longitude)
  end

end