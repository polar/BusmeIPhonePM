class MasterMainMenu < MenuScreen

  attr_accessor :mainController
  attr_accessor :masterController
  attr_accessor :masterMapScreen
  attr_accessor :journeySelectionScreen

  def self.newMenu(args)
    mainController     = args.delete :mainController
    masterMapScreen    = args.delete :masterMapScreen
    masterController   = args.delete :masterController
    m                  = self.new(args)
    m.masterMapScreen  = masterMapScreen
    m.masterController = masterController
    m.mainController   = mainController
    m.after_init
    m
  end

  def mainController=(mc)
    @mainController = WeakRef.new(mc)
  end

  def masterController=(mc)
    @masterController = WeakRef.new(mc)
  end

  def masterMapScreen(ms)
    @masterMapScreen = WeakRef.new(ms)
  end

  def reporting_menu
    {
        :title => "Reporting",
        :menu  => [
            {
                title:  "Driver",
                action: :report
            }, {
                title:  "Passenger",
                action: :report
            }, {
                title:  "Stop",
                action: :report
            }, {
                title:  "Logout",
                action: :report
            },
        ]
    }
  end

  def busme_transit_menu
    {
        :title => "Busme Transit Systems",
        :menu  => [{
                       title:  "Select",
                       action: :busme
                   }, {
                       title:  "Set as Default",
                       action: :busme
                   }, {
                       title:  "Remove As Default",
                       action: :busme
                   }]
    }
  end

  def nearby_menu
    state          = masterController.journeyVisibilityController.getCurrentState
    nearBy         = state.nearBy
    nearByDistance = masterController.journeyVisibilityController.nearByDistance
    types          = {}
    types[0]       = !nearBy ? :checkmark : :none
    types[2000]    = nearBy && nearByDistance == 2000 ? :checkmark : :none
    types[1000]    = nearBy && nearByDistance == 1000 ? :checkmark : :none
    types[500]     = nearBy && nearByDistance == 500 ? :checkmark : :none
    {
        :title => "Nearby Routes",
        :menu  => [{
                       :title          => "Show All",
                       :action         => :nearby,
                       :accessory_type => types[0]
                   }, {
                       :title          => "Only within 2000 feet",
                       :action         => :nearby,
                       :accessory_type => types[2000]
                   }, {
                       :title          => "Only within 1000 feet",
                       :action         => :nearby,
                       :accessory_type => types[1000]
                   }, {
                       :title          => "Only within 500 feet",
                       :action         => :nearby,
                       :accessory_type => types[500]
                   }
        ]
    }
  end

  def active_menu
    state = masterController.journeyVisibilityController.getCurrentState
    only  = state.onlyActive
    {
        :title => "Active Routes",
        :menu  => [{
                       :title          => "Show All",
                       :action         => :active,
                       :accessory_type => !state.onlyActive ? :checkmark : :none
                   }, {
                       :title          => "Show only Active",
                       :action         => :active,
                       :accessory_type => state.onlyActive ? :checkmark : :none
                   }
        ]
    }
  end

  def reload_menu
    {
        :title => "Reload",
        :menu  => [{
                       :title  => "Reload All",
                       :action => :reload
                   }
        ]
    }
  end

  def cancel_menu
    {
        :title  => "Cancel",
        :action => :cancel
    }
  end

  def menu_data
    [
        reporting_menu,
        busme_transit_menu,
        nearby_menu,
        active_menu,
        reload_menu
    ]
  end


  def report(screen, title)
    puts "REPORT #{title}"
    case title
      when "Driver", "Passenger"
        startReporting(screen, title)
      when "Stop"
        # TODO: Stop Reporting
        true
      when "Logout"
        # TODO: Logout
        true
    end
  end

  def startReporting(screen, title)
    if mainController
      if masterController = mainController.masterController
        if api = mainController.masterController.api
          # We should have at least one. Current can be later.
          if masterController.locationController.lastKnownLocation
            if !(login = api.loggedIn?)
              login            = Api::Login.new
              login.roleIntent = title == "Driver" ? :driver : :passenger
              login.quiet      = false
              login.loginTries = 0
              loginManager     = ReportingLoginManager.new(api, login)
              eventData        = Platform::LoginEventData.new(loginManager)
              login.loginState = Api::Login::LS_LOGIN
              api.uiEvents.postEvent("LoginEvent", eventData)
              true
            else
              if title == "Driver" && !login.roles.include?(:driver)
                @notAuthorizedView = BW::UIAlertView.default(
                    :title   => "Not Authorized",
                    :message => "You are not authorized as a driver, you are posting as a passenger"
                )
                @notAuthorizedView.show
                2.seconds.later do
                  if @notAuthorizedView
                    @notAuthorizedView.dismissWithClickedButtonIndex(0, animated: true)
                    @notAuthorizedView = nil
                  end
                end
                true
              else
                showSelections(screen)
              end
            end
          else
            #TODO: Check last update time
            @noLocationAlertView = BW::UIAlertView.default(
                :title   => "No Location",
                :message => "We have not yet gotten a GPS location from your device")
            @noLocationAlertView.show
            4.seconds.later do
              if @noLocationAlertView
                @noLocationAlertView.dismissWithClickedButtonIndex(0, animated: true)
                @noLocationAlertView = nil
              end
            end
            true
          end
        end
      end
    end
  end

  def showSelections(screen)
    self.journeySelectionScreen ||= JourneySelectionScreen.new(:nav_bar => true)
    journeySelectionScreen.parent = screen  # This is need to close up the menu
    journeySelectionScreen.masterController = mainController.masterController
    journeySelectionScreen.location         = mainController.masterController.locationController.currentLocation

    journeys = journeySelectionScreen.journeys
    if journeys.empty?
      alertView = BW::UIAlertView.new(
          :title => "No suitable journeys",
          :message => "Cannot find a suitable journey close to your location")
      alertView.show
      true
    else
      screen.open journeySelectionScreen
      false
    end
  end

  def busme(screen, title)
    puts "Busme #{title}"
    case title
      when "Select"
        mainController.uiEvents.postEvent("Main:select")
      when "Set as Default"
        if mainController && masterController
          str = mainController.busmeConfigurator.saveAsDefaultMaster(masterController.master)
          if str.nil?
            BW::App.alert("Error", :message => "Could not save #{masterController.master.name} as default transit system")
          else
            BW::App.alert("Done", :message => "#{masterController.master.name} is now your default transit system")
          end
        end
      when "Remove As Default"
        if mainController
          mainController.busmeConfigurator.removeDefaultMaster
          if masterController
            BW::App.alert("Done", :message => "#{masterController.master.name} is no longer your default transit system")
          else
            BW::App.alert("Done", :message => "You now have no default transit system")
          end
        end
    end
    true
  end

  def nearby(screen, title)
    puts "Neaby #{title}"
    case title
      when "Show All"
        masterController.journeyVisibilityController.setNearByState(false)
        masterController.api.uiEvents.postEvent("VisibilityChanged")
      when "Only within 2000 feet"
        masterController.journeyVisibilityController.nearByDistance = 2000
        masterController.journeyVisibilityController.setNearByState(true)
        masterController.api.uiEvents.postEvent("VisibilityChanged")
      when "Only within 1000 feet"
        masterController.journeyVisibilityController.nearByDistance = 1000
        masterController.journeyVisibilityController.setNearByState(true)
        masterController.api.uiEvents.postEvent("VisibilityChanged")
      when "Only within 500 feet"
        masterController.journeyVisibilityController.nearByDistance = 500
        masterController.journeyVisibilityController.setNearByState(true)
        masterController.api.uiEvents.postEvent("VisibilityChanged")
    end
    update_menu_data
    true
  end

  def active(screen, title)
    state = masterController.journeyVisibilityController.getCurrentState
    #puts "Active #{title}"
    case title
      when "Show All"
        if state.onlyActive
          masterController.journeyVisibilityController.setOnlyActiveState(false)
          masterController.api.uiEvents.postEvent("VisibilityChanged")
          update_menu_data
        end

      else
        if not state.onlyActive
          masterController.journeyVisibilityController.setOnlyActiveState(true)
          masterController.api.uiEvents.postEvent("VisibilityChanged")
          update_menu_data
        end
    end
    true
  end

  def reload(screen, title)
    case title
      when "Reload All"
        # post a reload followed by an immediate sync.
        masterController.api.bgEvents.postEvent("Master:reload")
        evd = Platform::JourneySyncEventData.new(isForced: true)
        masterController.api.bgEvents.postEvent("JourneySync", evd)
    end
    true
  end
end
