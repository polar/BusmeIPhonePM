class JourneySyncTimer
  include Platform::JourneySyncProgressEventDataConstants
  attr_accessor :masterController
  attr_accessor :pleaseStop

  def initialize(args)
    self.masterController = args[:masterController]
    masterController.api.uiEvents.registerForEvent("JourneySyncProgress", self)
    self.pleaseStop = false
  end

  def start
    self.pleaseStop = false
    doSync(true)
  end

  def stop
    self.pleaseStop = true
  end

  def restart
    self.pleaseStop = false
    doSync(false)
  end

  def kill
    self.pleaseStop = true
    self.masterController = nil
  end

  def doSync(forced)
    evd = Platform::JourneySyncEventData.new(isForced: forced)
    masterController.api.bgEvents.postEvent("JourneySync", evd) if masterController
  end

  def onBuspassEvent(event)
    case event.eventName
      when "JourneySyncProgress"
        onProgress(event.eventData)
    end
  end

  def onProgress(eventData)
    case eventData.action
      when P_DONE
        if !pleaseStop && masterController
          updateRate = (masterController.api.syncRate || 1000)/1000.0 || 1
          updateRate.seconds.later do
            doSync(false) if !@pleaseStop
          end
        end
    end
  end
end