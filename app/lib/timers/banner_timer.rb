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
    # In order to maintain the adding a removing of marker presentation foreground
    # we do the adds/removes, and roll on the single threaded background thread.
    # The roll will post UI Events to present and abandon markers.
    masterController.api.bgEvents.postEvent("Marker:roll", forced)
    masterController.api.bgEvents.postEvent("MasterMessage:roll")
    10.seconds.later do
        doBannerUpdate(false) unless @pleaseStop
    end unless pleaseStop
  end

  def onBuspassEvent(event)
    # Timers maybe getting killed, so various parts may not be around. Keep testing for them.
    return unless masterController

    case event.eventName
      when "Banner:roll"
        if masterController.bannerPresentationController
          masterController.bannerPresentationController.roll(event.eventData)
        end
      when "Marker:roll"
        if masterController.markerPresentationController
          masterController.markerPresentationController.roll(event.eventData)
        end
      when "MasterMessage:roll"
        if masterController.masterMessageController
          masterController.masterMessageController.roll(Utils::Time.current)
        end
    end
  end
end