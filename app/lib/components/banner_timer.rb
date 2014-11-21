class BannerTimer
  attr_accessor :masterController
  attr_accessor :pleaseStop

  # TODO: Banner Update Rate
  def initialize(args)
    self.masterController = args[:masterController]
    self.pleaseStop = false
    masterController.api.bgEvents.registerForEvent("Banner:roll", self)
    masterController.api.bgEvents.registerForEvent("Marker:roll", self)
    masterController.api.bgEvents.registerForEvent("MasterMessage:roll", self)
  end

  def start
    self.pleaseStop = false
    doBannerUpdate(true)
  end

  def stop
    self.pleaseStop = true
  end

  def kill
    self.pleaseStop = true
    self.masterController = nil
  end

  def restart
    self.pleaseStop = false
    doBannerUpdate(true)
  end

  def doBannerUpdate(forced)
    PM.logger.warn "BannerTimer:  Banner Update!! #{masterController}"
    return unless masterController
    masterController.api.bgEvents.postEvent("Banner:roll", forced)
    # In order to maintain the adding a removing of marker presentation components
    # we do the adds/removes, and roll on the single threaded background thread.
    # The roll will post UI Events to present and abandon markers.
    masterController.api.bgEvents.postEvent("Marker:roll", forced)
    masterController.api.bgEvents.postEvent("MasterMessage:roll")
    10.seconds.later do
        doBannerUpdate(false) unless @pleaseStop
    end unless pleaseStop
  end

  def onBuspassEvent(event)
    return unless masterController
    case event.eventName
      when "Banner:roll"
        masterController.bannerPresentationController.roll(event.eventData)
      when "Marker:roll"
        masterController.markerPresentationController.roll(event.eventData)
      when "MasterMessage:roll"
        masterController.masterMessageController.roll(Utils::Time.current)
    end
  end
end