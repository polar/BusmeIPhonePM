motion_require "json/pure"
class AppDelegate < PM::Delegate
  include Orientation
  include Platform::JourneySyncProgressEventDataConstants
  include Api::UpdateProgressConstants


  DISCOVER_URL = "http://busme-apis.herokuapp.com/apis/d1/get"


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
  attr_accessor :timersStarted

  attr_accessor :sem
  attr_accessor :menu

  attr_accessor :splashScreen

  def will_load(app, options = {})
    AppDelegate.status_bar(false)
  end
  def on_load(app, options = {})

    self.splashScreen = SplashScreen.new(:nav_bar => false, :imageName => "Default-568h@2x.png")

    self.eventsController = IPhone::EventsController.new(delegate: self)
    begin
      PM.logger.warn "Deleting Files"
      names = %w(
         Library/Caches/com.busme/syracuse-university-Journeys.xml
         Library/Caches/com.busme/syracuse-university-Markers.xml
         Library/Caches/com.busme/syracuse-university-Messages.xml)
      names.each do |name|
        PM.logger.warn "Deleting #{name}"
        File.delete(name) if File.exists?(name)
        PM.logger.warn "File.exists?(#{name})=#{File.exists?(name)}"
      end
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

    mainController.uiEvents.postEvent("Main:init", Platform::MainEventData.new)

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
    open splashScreen
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
    alertView = UIAlertView.alloc.initWithTitle("Contacting Bus Server",
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

  attr_accessor :networkErrorDialog
  def showTemporaryNetworkError
    self.networkErrorDialog ||= UIAlertView.alloc.initWithTitle("Network Error",
                                               message: "Cannot contact server temporarily",
                                               delegate:nil,
                                               cancelButtonTitle: nil,
                                               otherButtonTitles: nil)
    networkErrorDialog.show
    2.seconds.later do
      networkErrorDialog.dismissWithClickedButtonIndex(0, animated: true)
    end
    networkErrorDialog
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
    # TODO This has to be better.
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
      puts "Going to post #{@eventName} in 5 seconds"
      5.seconds.later do
        @app.mainController.uiEvents.postEvent(@eventName, @eventData)
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

  ##
  # Workflow:
  #   action/event -> reaction
  #   event => IntendedReceiver
  #
  # AppDelegate
  #   Main:Init:return ->
  #     on defaultMaster -> Main:Master:init => MainController
  #     on discover -> Main:Discover:init => MainController
  #
  #   Main:select -> Create DiscoverScreen ->
  #      Main:Discover:init => MainController -> Create DiscoverController ->
  #          Main:Discover:Init:return ->
  #            Search:init => DiscoverController
  #               Search:Init:Return -> enables DiscoverScreen
  #
  #   Main:Master:Init:return ->
  #        show Getting MasterDialog, build MasterScreen, register for MasterController events
  #        Master:init => MasterController
  #
  #   Master:Init:return ->
  #     on success
  #         End Init Dialog, switch to MasterScreen
  #     on error
  #         Error Dialog -> Main:init => MainController
  #
  # DiscoverScreen
  #   on long_press
  #      Search:discover => DiscoverController ->
  #          Search:Discover:return -> populate DiscoverScreen
  #   on tap
  #      Search:find => DiscoverController ->
  #        Search:Find:return -z.
  #         Select a master from screen, -> Main:Master:init => MainController
  #         Or, fire up MastersTableScreen, select master, -> Main:Master:init => MainController
  #
  # MainController
  #  Main:init ->
  #     Decides on Default Saved Master or to Discover ->
  #        Main:Init:return => AppDelegate
  #  Main:Master:init -> create MasterController ->
  #     Main:Master:Init:return => AppDelegate -> ShowDialog, start timers, etc, waiting for master to load
  #     Master:init => MasterController handles non-ui stuff
  # MasterController
  #   Master:init -> Contacts Server for Master
  #     Master:Init:return => AppDelegate
  #
  #  Search:init ->
  #     Search:Init:return


  def onBuspassEvent(event)
    PM.logger.info "AppDelegate: Got Event #{event.eventName}"
    case event.eventName
      when "Main:select"
        onMainSelect(event)
      when "Main:Init:return"
        onMainInitReturn(event)
      when "Main:Discover:Init:return"
        onMainDiscoverInitReturn(event)
      when "Search:Init:return"
        onSearchInitReturn(event)
      when "Main:Master:Init:return"
        onMainMasterInitReturn(event)
      when "Master:Init:return"
        onMasterInitReturn(event)
      when "JourneySyncProgress"
        onJourneySyncProgress(event)
      when "UpdateProgress"
        onUpdateProgress(event)
    end
    #PM.logger.info "AppDelegate: Finished with event #{event.eventName}"
  end

  # TODO: Move onUpdateProgress to an UpdateErrorController in rubylib and post a UIEvent to trigger a notification.
  UPDATE_ERROR_LIMIT = 5

  ##
  # We pay attention to starts, errors, and finishes. If we get a number of errors
  # in a period of time, then throw up a dialog.
  #
  def onUpdateProgress(event)
    @updateCount ||= 0
    evd = event.eventData
    case evd.action
      when U_START
        @updateCount += 1
      when U_REQ_IOERROR
        @updateError = @updateCount
      when U_FINISH
        if @updateError != @updateCount
          @updateCount = 0
          @updateError = nil
        elsif @updateCount > UPDATE_ERROR_LIMIT
          showTemporaryNetworkError
          @updateCount = 0
          @updateError = nil
        end
    end
  end

  ##
  # This event signifies that the first JourneySync has completed and we should start
  # The Sync and Update timers.
  #

  def onJourneySyncProgress(event)
    evd = event.eventData
    case evd.action
      when P_DONE
        if ! timersStarted && journeySyncTimer && updateTimer
          PM.logger.info "Starting Sync and UpdateTimers"
          journeySyncTimer.start
          updateTimer.start
          self.timersStarted = true
        end
    end
  end

  ##
  # This event signifies that the MasterController got or attempted to get API from the Server for the Master
  # If there is an HTTP Error, we'll just go back to the Main:init and start over.
  # If success, we do certain things pertaining to the master, like set up our Timezone, etc.
  def onMasterInitReturn(event)
    evd       = event.eventData
    alertView = evd.uiData
    if alertView && alertView.is_a?(UIAlertView)
      alertView.dismissWithClickedButtonIndex(0, animated: true)
    end
    if evd.error
      if evd.error.is_a? Api::HTTPError
        errorDialog("Network Error", evd.error.statusLine,
                    RestartOnCancel.new(self, "Main:init", Platform::MainEventData.new))
      else
        PM.logger.error "#{__method__}: Internal App Error: #{evd.error}"
      end
    else
      lastLocation = configurator.getLastLocation
      if lastLocation
        PM.logger.warn "#{__method__}: Have Last Location: #{lastLocation.inspect}"
      end
      PM.logger.info "#{__method__}: SETTING TIMEZONE TO #{mainController.masterController.api.buspass.timezone}"
      timeZone = NSTimeZone.timeZoneWithName mainController.masterController.api.buspass.timezone
      NSTimeZone.setDefaultTimeZone(timeZone) if timeZone
    end
  end

  def switchToMasterScreen
    if splashScreen
      splashScreen.close
    end
    if discoverScreen
      discoverScreen.close
    end
    if busmeMapScreen.nil? && discoverScreen.nil?
      PM.logger.warn "#{self.class.name}:#{__method__} Creating MapScreen"
      self.busmeMapScreen =
          MasterMapScreen.newScreen(nav_bar: true, :splash => splashScreen.imageName)
    else
      self.busmeMapScreen =
          MasterMapScreen.newScreen(nav_bar: true)
    end

    PM.logger.warn "#{self.class.name}:#{__method__} opening MapScreen"
    open(busmeMapScreen, :nav_bar => true)

  end

  ##
  # This method gets called on a Main:Master:Init:return event.
  #
  # The Discover Screen will fire off a "Main:Master:init" event when a master is selected, which
  # in turn creates a MasterController.
  # We catch the return event here on the UI Thread and switch to the master's screen, start
  # the timers, etc., i.e. operate the master, then fire off the "Master:init" event.
  #
  # There should not be an error, because the discover screen will either select a Master or
  # it will just stay there.
  #
  def onMainMasterInitReturn(event)
    evd = event.eventData
    if evd.uiData && evd.uiData.is_a?(UIAlertView)
      evd.uiData.dismissWithClickedButtonIndex(0, animated: true)
    end
    if evd.error
      PM.logger.error "#{__method__}: Internal App Error: #{evd.error}"
    else
      killTimers
      masterController, oldMasterController = evd.return

      PM.logger.info "AppDelegate: masterController: new #{masterController.__id__} old #{oldMasterController}"

      if oldMasterController
        eventsController.unregister(oldMasterController.api)
      end
      eventsController.register(masterController.api)

      # We register for this event to take down the dialog. The API is ready or there is a Network error.
      masterController.api.uiEvents.registerForEvent("Master:Init:return", self)
      # This event allows us to start the JourneySyncTimer and Update timers after the
      # MasterController's first initial sync.
      masterController.api.uiEvents.registerForEvent("JourneySyncProgress", self)
      masterController.api.uiEvents.registerForEvent("UpdateProgress", self)
      switchToMasterScreen

      self.busmeMapScreen.initWithMasterController(masterController)

      # Fire off the event to initialize the master, the return will allow us to take down the dialog or handle
      # an error.
      eventData = Platform::MasterEventData.new(:uiData => evd.uiData, :data => {:disposition => :default})
      masterController.api.bgEvents.postEvent("Master:init", eventData)

      # We set up the timers for JourneySync and Update
      # We don't start the JourneySync or Update Timer until it completes the first sync.
      self.timersStarted = false
      self.journeySyncTimer = JourneySyncTimer.new(masterController: masterController)
      self.updateTimer      = UpdateTimer.new(masterController: masterController)

      # We'll start the banners,message,marker timers right away.
      self.bannerTimer      = BannerTimer.new(masterController: masterController)
      bannerTimer.start
      if discoverScreen
        discoverScreen.close
      end
    end
  end

  def onSearchInitReturn(event)
    evd = event.eventData
    if evd.error
      if evd.error.is_a? Api::HTTPError
        errorDialog("Network Error", evd.error.statusLine,
                    RestartOnCancel.new(self, "Main:init", Platform::MainEventData.new))
      else
        PM.logger.error "#{__method__}: Internal App Error: #{evd.error}"
      end
    else
      loc = configurator.getLastLocation
      if loc
        if discoverScreen
          discoverScreen.performDiscoverFromLoc(false, loc)
        end
      end
    end
  end

  def onMainDiscoverInitReturn(event)
    evd       = event.eventData
    alertView = evd.uiData
    if alertView && alertView.is_a?(UIAlertView)
      alertView.dismissWithClickedButtonIndex(0, animated: true)
    end
    if evd.error
      PM.logger.error "#{__method__}: Internal App Error: #{evd.error}"
    else
      mainController.bgEvents.postEvent("Search:init", Platform::DiscoverEventData.new)
    end
  end

  ##
  # This event signifies that the MainController was created and it has decided
  # whether we are going to open a Master or a Discover.
  #
  attr_accessor :lookingForMasterDialog

  def onMainInitReturn(event)
    evd = event.eventData
    if evd.error
      PM.logger.error "#{__method__}: Internal App Error: #{evd.error}"
    else
      if evd.return && evd.return == "defaultMaster"
        master = evd.data[:master]
        if master
          masterApi = IPhone::Api.new(master)
          self.lookingForMasterDialog = showMasterDialog(master)
          eventData = Platform::MasterEventData.new(
              :uiData => lookingForMasterDialog,
              :data => {
                  :master    => master,
                  :masterApi => masterApi,
                  :disposition => :default
              },
          )
          mainController.bgEvents.postEvent("Main:Master:init", eventData)
          switchToMasterScreen
        else
          PM.logger.error "#{__method__}: Return 'defaultMaster' does not contain a master."
          createDiscoverScreen(false)
        end
      else # discover
        createDiscoverScreen(true)
      end
    end
  end

  def createDiscoverScreen(showDialog)
    if discoverScreen.nil? && busmeMapScreen.nil? && splashScreen
      self.discoverScreen =
          Discover1Screen.newScreen(mainController: mainController,
                                    nav_bar: true,
                                    splash: splashScreen.imageName)
    else
      self.discoverScreen =
          Discover1Screen.newScreen(mainController: mainController,
                                    nav_bar: true)
    end
    self.discoverApi    = IPhone::DiscoverApi.new(DISCOVER_URL)
    alertView           = showLookingDialog if showDialog

    mainController.bgEvents.postEvent(
        "Main:Discover:init",
        Platform::DiscoverEventData.new(
            uiData: alertView,
            data: {discoverApi: discoverApi}))
    open discoverScreen
  end

  ##
  # This event comes from the MainMenuController
  # If we have a MasterScreen open, then close it.
  # If we have a Discover screen, clear it, or create it, and open it.
  #  Main:Discover:init => MainController
  #
  def onMainSelect(event)
    if busmeMapScreen
      busmeMapScreen.close
      saveMaster(false)
    end
    killTimers
    createDiscoverScreen(true)
  end

  def stopTimers
    PM.logger.info "AppDelegate: Stopping Timers."
    journeySyncTimer.stop if journeySyncTimer
    bannerTimer.stop if bannerTimer
    updateTimer.stop if updateTimer
  end

  def killTimers
    PM.logger.info "AppDelegate: Killing Timers."
    journeySyncTimer.kill if journeySyncTimer
    bannerTimer.kill if bannerTimer
    updateTimer.kill if updateTimer
    self.journeySyncTimer = nil
    self.bannerTimer = nil
    self.updateTimer = nil
  end

  def resumeTimers
    PM.logger.info "AppDelegate: Resuming Timers."
    journeySyncTimer.restart if journeySyncTimer
    bannerTimer.restart if bannerTimer
    updateTimer.restart if updateTimer
  end

  def applicationWillTerminate(application)
    PM.logger.info "Application is terminating."
    saveMaster(true)
  end

  def saveMaster(asDefault = false)
    if mainController
      masterC = mainController.masterController
      if masterC
        evd = Platform::MasterEventData.new
        evd.data = { :masterController => masterC }
        masterC.api.bgEvents.postEvent("Master:store", evd)
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
          BW::App.delegate.mainController.uiEvents.postEvent("LocationUpdate", evd)
          if @mainController.masterController
            PM.logger.info "Posting to Master"
            BW::App.delegate.mainController.masterController.api.bgEvents.postEvent("LocationUpdate", evd)
            BW::App.delegate.mainController.masterController.api.uiEvents.postEvent("LocationUpdate", evd)
          end
          if BW::App.delegate.configurator
            BW::App.delegate.configurator.setLastLocation(loc)
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
    stopTimers
    saveMaster(false)
  end
  def applicationDidEnterBackground(application)
    puts "#{self.class.name}:#{self.__method__}"
  end
  def applicationWillEnterForeground(application)
    puts "#{self.class.name}:#{self.__method__}"
    resumeTimers
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
  def u(x=1)
    loc(@last_location.longitude, @last_location.latitude + 0.0001 * x)
  end
  def d(x=1)
    loc(@last_location.longitude, @last_location.latitude - 0.0001 * x)
  end
  def r(x=1)
    loc(@last_location.longitude + 0.0001 * x, @last_location.latitude)
  end
  def l(x=1)
    loc(@last_location.longitude - 0.0001 * x, @last_location.latitude)
  end

end
