class FGBusmeMapController
  attr_accessor :appDelegate
  attr_accessor :guts
  attr_accessor :mapScreen
  attr_accessor :currentMaster

  def initialize(args)
    self.appDelegate = args.delete :delegate
    self.guts = args.delete :guts
    self.mapScreen = args.delete :mapScreen
    mapScreen.controller = self

    registerForEvents(guts.api)
  end

  def registerForEvents(api)
    api.uiEvents.registerForEvent("Map:SetMaster", self)
    api.uiEvents.registerForEvent("BusmeApi:preSet", self)
    api.uiEvents.registerForEvent("BusmeApi:onSet", self)
    api.uiEvents.registerForEvent("BusmeApi:onGet", self)
  end

  def onBuspassEvent(event)
    case event.eventName
      when "Map:SetMaster"
        master = event.eventData
        if master
          self.currentMaster = master = event.eventData
          mapScreen.setMaster(currentMaster)
          api = IPhone::Api.new(master.apiUrl)
          appDelegate.eventsController.fixEventDistributors(api, master.slug)
          # We post on the old Events Distributor. It will get replaced by onSet.
          evd = Platform::BusmeApiSetEventData.new(master, api, "/tmp")
         #puts "FG BusmeMapController: SetMaster: Setting for Master #{master.slug}"
          guts.api.bgEvents.postEvent("BusmeApi:set", evd)
        else
         #puts "FG BusmeMapController: SetMaster: is Nil"
        end
        # This event comes from the BusmeAPIController when the api has been switched.
        # We need to reregister for at least the onSet and onGet
      when "BusmeApi:preSet"
       #puts "Current Master #{currentMaster} was set. Registering for Events"
        registerForEvents(guts.api)
      when "BusmeApi:onSet"
        # This event comes in on the new master specific events distirbutor.
       #puts "Current Master #{currentMaster} was set. Firing a Get"
        evd = Platform::BusmeApiGetEventData.new(nil, nil)
        guts.api.bgEvents.postEvent("BusmeApi:get", evd)
      when "BusmeApi:onGet"
        get = event.eventData.get
        if get
         #puts "FG BusmeMapController: onGet: master got #{get}"
          evd = Platform::JourneySyncEventData.new(true)
          guts.api.bgEvents.postEvent("JourneySync", evd)
        else
         #puts "Did not Get for current Master #{currentMaster}"
        end
    end
  end
end