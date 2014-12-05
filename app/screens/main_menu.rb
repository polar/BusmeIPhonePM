class DiscoverMainMenu < MenuScreen

  title "Main Menu"

  def help_menu
    {
        :title => "Help",
        :action => :help
    }
  end

  def menu_data
    [
        help_menu,
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

  def help(screen, title)
   PM.logger.info "Help #{title}"
  end

end