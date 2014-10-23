motion_require "json/pure"
class AppDelegate < PM::Delegate

  status_bar true, animation: :none

  attr_accessor :api
  attr_accessor :discoverApi
  attr_accessor :discoverScreen
  attr_accessor :busmeScreen

  attr_accessor :uiEvents
  attr_accessor :bgEvents

  attr_accessor :busmeMapScreen
  attr_accessor :fgBusmeMapController
  attr_accessor :eventsController
  attr_accessor :mainController
  attr_accessor :journeySyncTimer

  def on_load(app, options = {})

    self.eventsController = IPhone::EventsController.new(delegate: self)


    self.mainController = Platform::MainController.new(directory: File.join("Library", "Caches", "com.busme"))
    eventsController.register(mainController)
    mainController.uiEvents.registerForEvent("Main:Discover:Init:return", self)
    mainController.uiEvents.registerForEvent("Main:Master:Init:return", self)

    self.discoverApi =  IPhone::DiscoverApi.new("http://busme-apis.herokuapp.com/apis/d1/get")
    self.discoverScreen = Discover1Screen.newScreen(mainController: mainController, nav_bar: true)
    open discoverScreen
    alertView = showLookingDialog
    mainController.bgEvents.postEvent("Main:Discover:init",
           Platform::DiscoverEventData.new(uiData: alertView, data: {discoverApi: discoverApi}))
   # puts "#{::JSON.generate(['hello', 'world'])}"
  end

  def showLookingDialog
    alertView = UIAlertView.alloc.initWithTitle("Looking For Bus Server",
                                                message: nil,
                                                delegate:nil,
                                                cancelButtonTitle: nil,
                                                otherButtonTitles: nil)
    indicator = UIActivityIndicatorView.alloc.initWithActivityIndicatorStyle(UIActivityIndicatorViewStyleGray)
    indicator.startAnimating
    alertView.setValue(indicator, forKey: "accessoryView")
    alertView.show
    alertView
  end

  def showMasterDialog(master)
    alertView = UIAlertView.alloc.initWithTitle("Getting #{master.title}",
                                                message: nil,
                                                delegate:nil,
                                                cancelButtonTitle: nil,
                                                otherButtonTitles: nil)
    indicator = UIActivityIndicatorView.alloc.initWithActivityIndicatorStyle(UIActivityIndicatorViewStyleGray)
    indicator.startAnimating
    alertView.setValue(indicator, forKey: "accessoryView")
    alertView.show
    alertView
  end

  def onBuspassEvent(event)
    case event.eventName
      when "Main:Discover:Init:return"
        evd = event.eventData
        alertView = evd.uiData
        if alertView
          alertView.dismissWithClickedButtonIndex(0, animated: true)
        end
        mainController.bgEvents.postEvent("Search:init", Platform::DiscoverEventData.new)

      # The Discover Screen will fire off a "Main:Master:init" event when a master is selected.
      # We catch the return event here on the UI Thread and switch to the master's screen.
      when "Main:Master:Init:return"
        evd = event.eventData
        masterController = evd.return
        eventsController.register(masterController.api)
        discoverScreen.close
        self.busmeMapScreen = MasterMapScreen.newScreen(masterController: masterController, nav_bar: true)
        open busmeMapScreen
        alertView = showMasterDialog(masterController.master)
        eventData = Platform::MasterEventData.new(:uiData => alertView)
        masterController.api.uiEvents.registerForEvent("Master:Init:return", self)
        masterController.api.bgEvents.postEvent("Master:init", eventData)
        self.journeySyncTimer = JourneySyncTimer.new(masterController: masterController)

      when "Master:Init:return"
        evd = event.eventData
        alertView = evd.uiData
        if alertView
          alertView.dismissWithClickedButtonIndex(0, animated: true)
        end
    end
  end

end
