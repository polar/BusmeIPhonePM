

class MarkerAnnotation
  attr_accessor :markerInfo
  attr_accessor :type

  def initialize(markerInfo)
    self.markerInfo = markerInfo
    self.type = self.class.name
  end

  def coordinate
    CLLocationCoordinate2DMake(markerInfo.point.latitude, markerInfo.point.longitude)
  end

  def title
    markerInfo.title
  end

  def subtitle
    nil
  end
end