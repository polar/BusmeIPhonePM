class MasterMainMenu < MenuScreen

  attr_accessor :mainController
  attr_accessor :masterController
  attr_accessor :masterMapScreen

  def self.newMenu(args)
    mainController = args.delete :mainController
    masterMapScreen = args.delete :masterMapScreen
    masterController = args.delete :masterController
    m = self.new(args)
    m.masterMapScreen = masterMapScreen
    m.masterController = masterController
    m.mainController = mainController
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
        :menu => [
            {
                title: "Driver",
                action: :report
            },{
                title: "Passenger",
                action: :report
            },{
                title: "Stop",
                action: :report
            },{
                title: "Logout",
                action: :report
            },{
                title: "Cancel",
                action: :cancel
            }
        ]
    }
  end

  def busme_transit_menu
    {
        :title => "Busme Transit Systems",
        :menu =>[{
                     title: "Select",
                     action: :busme
                 },{
                     title: "Set as Default",
                     action: :busme
                 },{
                     title: "Remove As Default",
                     action: :busme
                 },{
                     title: "Cancel",
                     action: :cancel
                 }]
    }
  end

  def nearby_menu
    state = masterController.journeyVisibilityController.getCurrentState
    nearBy = state.nearBy
    nearByDistance = masterController.journeyVisibilityController.nearByDistance
    types = {}
    types[0] = !nearBy ? :checkmark : :none
    types[2000] = nearBy && nearByDistance == 2000 ? :checkmark : :none
    types[1000] = nearBy && nearByDistance == 1000 ? :checkmark : :none
    types[500] = nearBy && nearByDistance == 500 ? :checkmark : :none
    {
        :title => "Nearby Routes",
        :menu => [{
                      :title => "Show All",
                      :action => :nearby,
                      :accessory_type => types[0]
                  },{
                      :title => "Only within 2000 feet",
                      :action => :nearby,
                      :accessory_type => types[2000]
                  },{
                      :title => "Only within 1000 feet",
                      :action => :nearby,
                      :accessory_type => types[1000]
                  },{
                      :title => "Only within 500 feet",
                      :action => :nearby,
                      :accessory_type => types[500]
                  }
        ]
    }
  end

  def active_menu
    state = masterController.journeyVisibilityController.getCurrentState
    only = state.onlyActive
    {
        :title => "Active Routes",
        :menu => [{
                      :title => "Show All",
                      :action => :active,
                      :accessory_type => ! state.onlyActive ? :checkmark : :none
                  },{
                      :title => "Show only Active",
                      :action => :active,
                      :accessory_type => state.onlyActive ? :checkmark : :none
                  }
        ]
    }
  end


  def cancel_menu
    {
        :title => "Cancel",
        :action => :cancel
    }
  end

  def menu_data
    [
        reporting_menu,
        busme_transit_menu,
        nearby_menu,
        active_menu,
        cancel_menu
    ]
  end

  def report(title)
   #puts "REPORT #{title}"
  end

  def busme(title)
   #puts "Busme #{title}"
    case title
      when "Select"
        mainController.uiEvents.postEvent("Main:select")
      when "Select As Default"
      when "Remove As Default"
    end
  end

  def nearby(title)
   #puts "Neaby #{title}"
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
  end

  def active(title)
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
  end
end