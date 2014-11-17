class BannerTimer
  attr_accessor :masterController
  attr_accessor :pleaseStop

  def initialize(args)
    self.masterController = args[:masterController]
    self.pleaseStop = true
    masterController.api.bgEvents.registerForEvent("Marker:roll", self)
  end

  def start
    self.pleaseStop = false
    doBannerUpdate(true)
  end

  def stop
    self.pleaseStop = true
  end

  def restart
    self.pleaseStop = false
    doBannerUpdate(true)
  end

  def doBannerUpdate(forced)
    PM.logger.warn "BannerTimer:  Banner Update!!"
    masterController.bannerPresentationController.roll(forced)
    # In order to maintain the adding a removing of marker presetnation components
    # we do the adds/removes, and roll on the single threaded background thread.
    # The roll will post UI Events to present and abandon markers.
    masterController.api.bgEvents.postEvent("Marker:roll", forced)
    5.seconds.later do
      if ! pleaseStop
        doBannerUpdate(false)
      end
    end
  end

  def onBuspassEvent(event)
    case event.eventName
      when "Marker:roll"
        masterController.markerPresentationController.roll(event.eventData)
    end
  end
end