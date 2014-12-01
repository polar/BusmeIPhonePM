class DiscoverMainMenu < MenuScreen

  def kill_menu
    {
        :title => "Exit",
        :menu => [{
            :title => "Exit Now",
            :action => :exit_now
                  },
            cancel_menu
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
                 },
                  cancel_menu
        ]
    }
  end

  def cancel_menu
    {
        title: "Cancel",
        action: :cancel
    }
  end

  def menu_data
    [
        busme_transit_menu,
        kill_menu,
        cancel_menu
    ]
  end

  attr_accessor :discoverScreen

  def self.newMenu(args)
    discoverScreen = args.delete :discoverScreen
    m = self.new(args)
    m.discoverScreen = discoverScreen
    m.after_init
    m
  end

  def discoverScreen=(ds)
    @discoverScreen = WeakRef.new(ds)
  end

  def exit_now(title)
   #puts "Exit #{title}"
  end

  def busme(screen, title)
   #puts "BUSME #{title}"
    case title
      when "Select"
      when "Select As Default"
      when "Remove As Default"

    end
  end
end