motion_require "json/pure"
class AppDelegate < PM::Delegate
  include Orientation
  include Platform::JourneySyncProgressEventDataConstants

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
  attr_accessor :configurator
  attr_accessor :mainController
  attr_accessor :journeySyncTimer
  attr_accessor :updateTimer
  attr_accessor :locationManager
  attr_accessor :bannerTimer

  attr_accessor :sem
  attr_accessor :menu

  def on_load(app, options = {})

    self.eventsController = IPhone::EventsController.new(delegate: self)
    begin
      File.delete("Library/Caches/com.busme/syracuse-university-Journeys.xml")
      File.delete("Library/Caches/com.busme/syracuse-university-Markers.xml")
      File.delete("Library/Caches/com.busme/syracuse-university-Messages.xml")
    rescue Exception => boom
      puts "#{boom}"
    end if false


    self.configurator = Configurator.new
    self.mainController = ::MainController.new(
        directory: File.join("Library", "Caches", "com.busme"),
        busmeConfigurator: configurator)
    eventsController.register(mainController)
    mainController.uiEvents.registerForEvent("Main:select", self)
    mainController.uiEvents.registerForEvent("Main:Init:return", self)
    mainController.uiEvents.registerForEvent("Main:Discover:Init:return", self)
    mainController.uiEvents.registerForEvent("Main:Master:Init:return", self)
    mainController.uiEvents.registerForEvent("Search:Init:return", self)

    mainController.bgEvents.postEvent("Main:init", Platform::MainEventData.new)

    #puts "Device generatesOrientationNotifications #{UIDevice.currentDevice.generatesDeviceOrientationNotifications}"
    UIDevice.currentDevice.beginGeneratingDeviceOrientationNotifications
    @current_orientation = UIDevice.currentDevice.orientation
    if device_landscape?(@current_orientation)
      @current_bounds = screenSize
    end
    setupLocationManager
    c = CLLocation.alloc.initWithLatitude(43.0, longitude: -76.9)
    p c.description
    NSLog("c.coordinate: #{c.coordinate}")
    p c.coordinate
    self
  end

  def screenSize
    size = UIScreen.mainScreen.bounds.size
    if NSFountationVersionNumber <= NSFoundationVersionNumber_iOS_7_1 && interface_landscape?(UIApplication.sharedApplication.statusBarOrientation)
      size = CGMakeSize(size.height, size.width)
    end
    size
  end

  def applicationDidReceiveMemoryWarning(application)
    puts "***************  Aplication  Memory Warning  ***************************"
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

  attr_accessor :restartOnCancel
  class RestartOnCancel
    attr_accessor :app
    attr_accessor :eventName
    attr_accessor :eventData
    def initialize(app, eventName, eventData)
      self.app = app
      app.restartOnCancel = self
      self.eventName = eventName
      self.eventData = eventData
    end

    def alertView(alertView, willDismissWithButtonIndex: buttonIndex)
      puts "RestartOnCancel: alertView will dismiss with #{buttonIndex}"
      puts "Going to post Main:Init in 5 seconds"
      5.seconds.later do
        @app.mainController.bgEvents.postEvent(@eventName, @eventData)
        @app.restartOnCancel = nil
        @app = nil
      end
    end

    # This method never gets called.
    def alertViewCancel(alertView)
      puts "RestartOnCancel: alertViewCancel!"
    end
  end

  def errorDialog(title, statusLine, delegate)
    alertView = UIAlertView.alloc.initWithTitle(title,
                                                message: statusLine.reasonPhrase,
                                                delegate: delegate,
                                                cancelButtonTitle: "OK",
                                                otherButtonTitles: nil)
    alertView.show
    alertView
  end

  def onBuspassEvent(event)
    PM.logger.info "AppDelegate: Got Event #{event.eventName}"
    case event.eventName
      when "Main:select"
        evd = event.eventData
        alertView = showLookingDialog
        if busmeMapScreen
          busmeMapScreen.close
          saveMaster(false)
        end
        mainController.bgEvents.postEvent("Main:Discover:init",
                                          Platform::DiscoverEventData.new(uiData: alertView,
                                                                          data: {discoverApi: discoverApi}))
        if discoverScreen
          discoverScreen.clear
        else
          self.discoverApi =  IPhone::DiscoverApi.new("http://busme-apis.herokuapp.com/apis/d1/get")
          self.discoverScreen = Discover1Screen.newScreen(mainController: mainController, nav_bar: true)
          alertView = showLookingDialog
          mainController.bgEvents.postEvent("Main:Discover:init",
                                            Platform::DiscoverEventData.new(uiData: alertView, data: {discoverApi: discoverApi}))
        end
        open discoverScreen
      when "Main:Init:return"
        evd = event.eventData
        if evd.return && evd.return == "defaultMaster"
          master = evd.data[:master]
          if master
            masterApi = IPhone::Api.new(master)
            eventData = Platform::MasterEventData.new(
              :data => {
                :master => master,
                :masterApi => masterApi
              },
            )
            mainController.bgEvents.postEvent("Main:Master:init", eventData)
          end
        else # discover
          self.discoverApi =  IPhone::DiscoverApi.new("http://busme-apis.herokuapp.com/apis/d1/get")
          self.discoverScreen = Discover1Screen.newScreen(mainController: mainController, nav_bar: true)
          alertView = showLookingDialog
          mainController.bgEvents.postEvent("Main:Discover:init",
                                            Platform::DiscoverEventData.new(uiData: alertView, data: {discoverApi: discoverApi}))
          open discoverScreen
        end
      when "Main:Discover:Init:return"
        evd = event.eventData
        alertView = evd.uiData
        if alertView
          alertView.dismissWithClickedButtonIndex(0, animated: true)
        end
        mainController.bgEvents.postEvent("Search:init", Platform::DiscoverEventData.new)
      when "Search:Init:return"
        evd = event.eventData
        status = evd.return
        if !status
          status = Integration::Http::StatusLine.new(500, "Internal App Error, No Api")
        end
        if status.is_a?(Integration::Http::StatusLine)
          # It's an error, restart.
          errorDialog("Network Error", status, RestartOnCancel.new(self, "Main:init", Platform::MainEventData.new))
        else
          loc = configurator.getLastLocation
          if loc
            mainController.bgEvents.postEvent("Search:discover", Platform::DiscoverEventData.new(
                :data => { :lon => loc.longitude, :lat => loc.latitude, :buf => 10000 }
            ))
          end
        end
      # The Discover Screen will fire off a "Main:Master:init" event when a master is selected.
      # We catch the return event here on the UI Thread and switch to the master's screen.
      when "Main:Master:Init:return"
        evd = event.eventData
        masterController = evd.return
        PM.logger.info "AppDelegate: masterController: #{masterController.__id__}"
        alertView = showMasterDialog(masterController.master)
        eventsController.register(masterController.api)
        PM.logger.info "AppDelegate: closing Discover Screen"
        discoverScreen.close if discoverScreen
        PM.logger.info "AppDelegate: closed Discover Screen"
        self.busmeMapScreen = MasterMapScreen.newScreen(masterController: masterController, nav_bar: true)
        PM.logger.info "AppDelegate: Opening Master Map Screen"
        open busmeMapScreen
        PM.logger.info "AppDelegate: Opened Master Map Screen"
        eventData = Platform::MasterEventData.new(:uiData => alertView)
        masterController.api.uiEvents.registerForEvent("Master:Init:return", self)
        # This event allows us to start the UpdateTimer after the first sync.
        masterController.api.uiEvents.registerForEvent("JourneySyncProgress", self)
        masterController.api.bgEvents.postEvent("Master:init", eventData)
        # We set up the timers for JourneySync and Update, but we don't start them
        # until after each one has completed its first one.
        self.journeySyncTimer = JourneySyncTimer.new(masterController: masterController)
        self.updateTimer = UpdateTimer.new(masterController: masterController)
        # We'll start the banners right away.
        self.bannerTimer = BannerTimer.new(masterController: masterController)
        bannerTimer.start

      when "Master:Init:return"
        evd = event.eventData
        alertView = evd.uiData
        if alertView
          alertView.dismissWithClickedButtonIndex(0, animated: true)
        end
        status = evd.return
        if status.is_a?(Integration::Http::StatusLine)
          errorDialog("Network Error", status, RestartOnCancel.new(self, "Main:init", Platform::MainEventData.new))
        else
          lastLocation = configurator.getLastLocation
          if lastLocation
            mainController.bgEvents.postEvent("Search:init", Platform::DiscoverEventData.new())
          end
          PM.logger.info "SETTING TIMEZONE TO #{mainController.masterController.api.buspass.timezone}"
          timeZone = NSTimeZone.timeZoneWithName mainController.masterController.api.buspass.timezone
          NSTimeZone.setDefaultTimeZone(timeZone) if timeZone
        end

      when "JourneySyncProgress"
        evd = event.eventData
        case evd.action
          when P_DONE
            if updateTimer.pleaseStop == true && journeySyncTimer.pleaseStop == false
              updateTimer.start
              journeySyncTimer.start
            end
        end
    end
    #PM.logger.info "AppDelegate: Finished with event #{event.eventName}"
  end

  def applicationWillTerminate(application)
    PM.logger.info "Application is terminating."
    saveMaster(true)
  end

  def saveMaster(asDefault = false)
    if mainController
      masterC = mainController.masterController
      if masterC
        masterC.storeMaster
        if asDefault
          PM.logger.info "Setting default Master to #{masterC.master.name}"
          configurator.setDefaultMaster(masterC.master)
        end
      end
    end
  end

  def should_rotate(orientation)
    PM.logger.info "AppDelegate: should_rotate(#{interface_orientation_names[orientation]})"
    PM.logger.info "AppDelegate: should_rotate Interface #{interface_orientation_names[UIApplication.sharedApplication.statusBarOrientation]} superview.frame #{view.superview.inspect} bounds #{bounds.inspect}"
  end

  def will_rotate(orientation, duration)
    PM.logger.info "AppDelegate: will_rotate(#{interface_orientation_names[orientation]}, #{duration})"
    PM.logger.info "AppDelegate: will_rotate Interface #{interface_orientation_names[UIApplication.sharedApplication.statusBarOrientation]} superview.frame #{view.superview.inspect} bounds #{bounds.inspect}"
  end

  def on_rotate
    #puts "AppDelegate: on_rotate(#{interface_orientation_names[orientation]})"
    PM.logger.info "AppDelegate: on_rotate Interface #{interface_orientation_names[UIApplication.sharedApplication.statusBarOrientation]} superview.frame #{view.superview.inspect} bounds #{bounds.inspect}"
  end

  def setupLocationManager
    PM.logger.info "AppDelegate: set up LocationManager"
    BubbleWrap::Location.get(distance_filter:10, desired_accuracy: :nearest_ten_meters) do |result|
      @count == (@count || 0) + 1
      if result[:error]
        PM.logger.info "Error getting Location #{result[:error]}"
      elsif result[:to]
        PM.logger.info "Got Location #{result.inspect}"
        PM.logger.info "Got Location #{[]}"
        PM.logger.info "Got Location #{result[:to]}"
        PM.logger.info "Got Location #{result[:to].coordinate.inspect}"
        PM.logger.info "Got Location #{result[:to].coordinate.longitude}, #{result[:to].coordinate.latitude}"
        loc = Platform::Location.new("Location#{@count}", result[:to].coordinate.longitude, result[:to].coordinate.latitude)
        PM.logger.info "Got Location #{loc}"
        evd = Platform::LocationEventData.new(loc)
        PM.logger.info "Submitting #{evd}"
        if BW::App.delegate.mainController
          PM.logger.info "Posting to Main"
          BW::App.delegate.mainController.bgEvents.postEvent("LocationUpdate", evd)
          if @mainController.masterController
            PM.logger.info "Posting to Master"
            BW::App.delegate.mainController.masterController.api.bgEvents.postEvent("LocationUpdate", evd)
          end
          PM.logger.info "Posting Done"
        end
      else
        PM.logger.info "Got nothing for location #{result.inspect}"
      end
      PM.logger.info "Location.get DONE"
    end
  end

  # For REPL for now
  @last_location
  def loc(lon,lat)
    m = BubbleWrap::Location.location_manager
    c = CLLocation.alloc.initWithLatitude(lat, longitude: lon)
    PM.logger.info "Setting up #{c}"
    #PM.logger.info "Setting up #{c.coordinate}"
    #PM.logger.info "Setting up #{c.coordinate.latitude} #{c.coordinate.longitude}"
    BubbleWrap::Location.locationManager(m, didUpdateToLocation: c, fromLocation: @last_location)
    @last_location = c
  end

  def applicationDidBecomeActive(application)
    puts "#{self.class.name}:#{self.__method__}"
  end
  def applicationWillResignActive(application)
    puts "#{self.class.name}:#{self.__method__}"
  end
  def applicationDidEnterBackground(application)
    puts "#{self.class.name}:#{self.__method__}"
  end
  def applicationWillEnterForeground(application)
    puts "#{self.class.name}:#{self.__method__}"
  end
  def applicationWillTerminate(application)
    puts "#{self.class.name}:#{self.__method__}"
  end

  def to_s
    "<AppDelegate>"
  end
  def inspect
    to_s
  end

  def locsyr
    loc(-76.1315307617188, 43.03726196289)
  end

end
