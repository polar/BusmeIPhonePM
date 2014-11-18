class UpdateTimer
  include Api::UpdateProgressConstants
  attr_accessor :masterController
  attr_accessor :pleaseStop

  def initialize(args)
    self.masterController = args[:masterController]
    masterController.api.uiEvents.registerForEvent("UpdateProgress", self)
    # Initially this timer is off, until it gets started by the first JourneySync
    self.pleaseStop = true
  end

  def start
   #puts "UpdateTimer:start"
    self.pleaseStop = false
    doUpdate(true)
  end

  def stop
    self.pleaseStop = true
  end

  def restart
   #puts "UpdateTimer:restart"
    self.pleaseStop = false
    doUpdate(false)
  end

  def doUpdate(forced)
    eatme = Platform::JourneySyncEventData.new({})
    evd = Platform::UpdateEventData.new(isForced: forced)
    masterController.api.bgEvents.postEvent("Update", evd)
  end

  def onBuspassEvent(event)
   #puts "UpdateTime.gotEvent #{event.eventName}"
    case event.eventName
      when "UpdateProgress"
        onProgress(event.eventData)
    end
  end

  def onProgress(eventData)
    case eventData.action
      when U_FINISH
        if !pleaseStop
          updateRate = (masterController.api.updateRate || 1000)/1000.0 || 10
         #puts "UpdatetTimer: schedule #{updateRate}"
          updateRate.seconds.later do
           #puts "UpdateTimer: update pleaseStop #{@pleaseStop}"
            doUpdate(false) if !@pleaseStop
           #puts "UpdateTimer: update finished #{@pleaseStop}"
          end
         #puts "UpdatetTimer: Scheduled! #{updateRate}"
        end
      else
    end
  end
end