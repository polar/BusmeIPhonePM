
class FGMarkerPresentationEventController < Platform::FG_MarkerPresentationEventController
  include SugarCube::CoreGraphics

  attr_accessor :masterMapScreen

  def initialize(api, masterMapScreen)
    super(api)
    self.masterMapScreen = masterMapScreen
  end

  def presentMarker(eventData)
    marker = eventData.marker_info
    puts "FGMarkerPresentation. presentMarker(#{marker.inspect})"
    m = UIMarker.markerWith(marker)
    loc = CLLocationCoordinate2DMake(marker.point.latitude, marker.point.longitude)
    # TODO: NEED TO Translate infor to a hash.
    a = PM::MapScreenAnnotation.new(marker)
    masterMapScreen.add_annotation a
  end
end