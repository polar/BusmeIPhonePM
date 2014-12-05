
class FGMarkerPresentationEventController < Platform::FG_MarkerPresentationEventController
  include SugarCube::CoreGraphics

  attr_accessor :masterMapScreen

  def initialize(api, masterMapScreen)
    super(api)
    self.masterMapScreen = masterMapScreen
  end

  def presentMarker(eventData)
    marker = eventData.marker_info
    PM.logger.info "FGMarkerPresentation. presentMarker(#{marker.inspect})"
    masterMapScreen.addMarker(marker)
  end

  def abandonMarker(eventData)
    marker = eventData.marker_info
    PM.logger.info "FGMarkerPresentation. abandonMarker(#{marker.inspect})"
    masterMapScreen.removeMarker(marker)
  end
end