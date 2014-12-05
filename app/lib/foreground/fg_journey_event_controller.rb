class FGJourneyEventController < Platform::JourneyEventController
  attr_accessor :masterMapScreen

  def initialize(api, masterMapScreen)
    super(api)
    self.masterMapScreen = masterMapScreen
  end

  def onRoutePosting(eventData)
    PM.logger.info "#{self.class.name}:#{__method__} #{eventData.route.name} action #{eventData.action} reason #{eventData.reason}"

  end

  def atRouteStart(eventData)
    PM.logger.info "#{self.class.name}:#{__method__} #{eventData.route.name} action #{eventData.action} reason #{eventData.reason}"


  end

  def offRoute(eventData)
    PM.logger.info "#{self.class.name}:#{__method__} #{eventData.route.name} action #{eventData.action} reason #{eventData.reason}"


  end

  def onRoute(eventData)
    PM.logger.info "#{self.class.name}:#{__method__} #{eventData.route.name} action #{eventData.action} reason #{eventData.reason}"


  end

  def updateRoute(eventData)
    PM.logger.info "#{self.class.name}:#{__method__} #{eventData.route.name} action #{eventData.action} reason #{eventData.reason}"

  end

  def atRouteEnd(eventData)
    PM.logger.info "#{self.class.name}:#{__method__} #{eventData.route.name} action #{eventData.action} reason #{eventData.reason}"

  end

  def onRouteDone(eventData)
    PM.logger.info "#{self.class.name}:#{__method__} #{eventData.route.name} action #{eventData.action} reason #{eventData.reason}"

    message = nil
    case eventData.reason
      when Platform::JourneyEventData::R_NORMAL
        message = "Journey #{eventData.route.name} Ended"
      when Platform::JourneyEventData::R_FORCED
      when Platform::JourneyEventData::R_DISABLED
        message = "Location Provider Disabled"
      when Platform::JourneyEventData::R_SERVICE
      when Platform::JourneyEventData::R_OFF_ROUTE
        message = "You are too far off route for #{eventData.route.code} #{eventData.route.name}"
      when Platform::JourneyEventData::R_NOT_AVAILABLE
        message = "Route #{eventData.route.code} #{eventData.route.name} is not available for reporting at this time"
    end
    if message
      PM.logger.info "#{self.class.name}:#{__method__} #{message}"

      @onRouteDoneView = BW::UIAlertView.default(
                                            :title => "Reporting Ended",
                                            :message => message,
                                            :buttons => ["OK"]
      )
      @onRouteDoneView.show
      4.seconds.later do
        if @onRouteDoneView
          @onRouteDoneView.dismissWithClickedButtonIndex(0, animated: true)
          @onRouteDoneView = nil
        end
      end
    end
  end
end