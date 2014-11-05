class MastersTableScreen < PM::TableScreen
  title "Muncipalities"
  refreshable
  searchable placeholder: "Search Municipalities"

  attr_accessor :mainController

  # initialize doesn't get called because Promotion overrides new
  def self.newScreen(args)
    puts "Initialize MastersTable Screen"
    mainController = args.delete :mainController
    puts "Initialize MastersTable Screen #{mainController}"
    s = self.new(args)
    s.mainController = mainController
    s.after_init
    s
  end

  def after_init
    set_nav_bar_button :back, :title => "Back", :style => :plain, :action => :back
    update_table_data
  end

  def table_data
    if mainController
      masters = mainController.discoverController.masters
      @table_data = [{
                         cells: masters.map do |master|
                          { :title => master.name,
                            :action => :select_master,
                            :arguments => { :master => master } }
                         end
                     }]
    else
      []
    end
  end

  def select_master(args)
    master = args[:master]
    if master
      masterApi = IPhone::Api.new(master)
      eventData = Platform::MasterEventData.new(
          :data => { :master => master, :masterApi => masterApi}
      )
      mainController.bgEvents.postEvent("Main:Master:init", eventData)
    end
  end
end