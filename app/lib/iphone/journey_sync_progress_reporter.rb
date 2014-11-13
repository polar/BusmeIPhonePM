class JourneySyncProgressReporter
  attr_accessor :masterController
  def initialize(masterController)
    self.masterController = masterController
    masterController.api.uiEvents.registerForEvents("JourneySyncProgress", self)
  end

  def onBuspassEvent(event)
    evd = event.eventData
   #puts "JourneySyncProgress: #{evd.inspect}"
  end
end