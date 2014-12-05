
class MarkerAnnotationView <  MKAnnotationView

  attr_reader :masterMapScreen

  @@count = 0
  def self.get(marker, masterMapScreen)
    @@count += 1
    PM.logger.info "MarkerAnnoationView.get #{marker.inspect} #{@@count}"
    mv = self.alloc.initWithAnnotation(marker, reuseIdentifier:"Marker#{@@count}")
    mv.setup(masterMapScreen)
    mv
  end

  def markerInfo
    annotation.markerInfo
  end

  def centerOffset
    # The damn documentation says that positive values "move" down and to the right.
    # and negative values "move" up and to the left. I guess that depends on your
    # perspective. We need to move the view so that the coordinate is at the
    # bottom left, which I would think means move the picture from its intended
    # point up half the height and to the right half the width, i.e. negative, positive.
    # So, I don't really know what the documentation's logical
    # perspective is, but it's the opposite. And it still looks off.
    point = CGPoint.new(self.size.width/2, 0 - self.size.height/2)
    puts "MarkerEAnnotationView.centerOffset. #{self.size.inspect} offset #{point.inspect}"
    point
  end

  attr_accessor :markerView
  def setup(masterMapScreen)
    self.markerView = UIMarker.markerWith(markerInfo, masterMapScreen)
    self.size = markerView.size
    markerView.add(self, :at => CGPoint.new(0,0))
  end
end