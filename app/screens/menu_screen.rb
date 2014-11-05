class MenuScreen < PM::TableScreen
  title "Menu"
  attr_accessor :parent

  def menu_data
    @menu_data
  end

  def menu_data=(m)
    @menu_data = m
  end

  def self.newScreen(parent, title, menu_data)
    m = MenuScreen.new(nav_bar: true)
    m.title = title
    m.menu_data = menu_data
    m.parent = WeakRef.new(parent)
    m
  end

  def on_load
    #frame [[0,0],[UIScreen.mainScreen.bounds.size.width/2, UIScreen.mainScreen.bounds.size.height]]
    #size ["50%", "80%"]
    set_nav_bar_button :back, :title => "Back", :style => :plain, :action => :back
  end

  def on_init
    @menus = []
    @table_cells = nil
  end

  def after_init
    make_menus
  end

  def make_menus
    @menus = []
    @table_cells = []
    menu_data.each do |cell|
      puts "Make Menu #{cell[:menu].inspect}"
      if cell[:menu]
        m = make_menu(self, cell[:title], cell[:menu])
        @table_cells << { title: cell[:title], action: :open_menu, arguments: m, accessory_type: :disclosure_indicator}
        @menus << m
      else
        if cell[:action].to_sym == :cancel
          @table_cells << { title: cell[:title], action: :cancel }
        else
          item = cell.dup
          action = item[:action]
          item[:action] = :doit
          item[:arguments] = [action, cell[:title], cell[:arguments]]
          if item[:accessory] && (act1 = item[:accessory][:action])
            item[:accessory][:action] = :doit
            item[:accessory][:arguments] = [act1, cell[:title], item[:accesory][:arguments]]
          end
          @table_cells << item
        end
      end
    end
  end

  def doit(args)
    action, title, arguments = args
    p = self
    while p.parent != nil
      p = p.parent
    end
    if p.respond_to? action
      arguments ||= []
      arguments = [arguments] unless arguments.is_a?(Array)
      arguments = [title] + arguments
      p.send(action, *arguments)
    end
    close_up
  end

  def make_menu(parent, title, cell)
    MenuScreen.newScreen(parent, title, cell)
  end

  def open_menu(menu)
    open menu
  end

  def update_menu_data
    make_menus
    update_table_data
  end

  def table_data
    make_menus if @table_cells.nil?
    @table_data =
      [{ title: title,
         cells: @table_cells }]
  end

  def close_up
    p = self
    while p.parent != nil
      p.close
      p = p.parent
    end
    p.close
  end

  def cancel
    puts "Cancel"
    p = self
    while p.parent != nil
      puts "cancel #{p}"
      p.close
      p = p.parent
    end
    puts "Closing #{p}"
    p.close
  end

end