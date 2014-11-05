class DiscoverMainMenu < MenuScreen

  def test_menu
    {
        :title => "Test",
            :menu => [{
                      :title => "Eatme 1",
                      :action => :test,
                      :accessory_type => :none
                  },{
                      :title => "Eatme 2",
                      :action => :test,
                      :accessory_type => :disclosure_indicator
                  },{
                      :title => "Eatme 3",
                      :action => :test,
                      :accessory_type => :disclosure_button
                  },{
                      :title => "Eatme 4",
                      :action => :test,
                      :accessory_type => eatme ? :checkmark : :none
                  },{
                      :title => "Eatme 5",
                      :action => :test,
                      :accessory_type => :detail_button
                  }]
    }
  end
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

  attr_accessor :eatme

  def test(title)
    puts "Test #{title}"
    if title == "Eatme 4"
      self.eatme = !eatme
      puts "eatme == #{eatme}"
      update_menu_data
    end
  end
  def exit_now(title)
    puts "Exit #{title}"
  end

  def busme(title)
    puts "BUSME #{title}"
  end
end