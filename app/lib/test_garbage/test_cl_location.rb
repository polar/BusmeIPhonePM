class TestCLLocation
  attr_accessor :coordinate
  def initialize(lat, lon)
    self.coordinate = CLLocationCoordinate2D.new(lat, lon)
  end
end