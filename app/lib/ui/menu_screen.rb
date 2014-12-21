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
      PM.logger.info "Make Menu #{cell[:menu].inspect}"
      if cell[:menu]
        m = make_menu(self, cell[:title], cell[:menu])
        @table_cells << { title: cell[:title], action: :open_menu, arguments: m, accessory_type: :disclosure_indicator}
        @menus << m
      else
        if cell[:action] && cell[:action].to_sym == :cancel
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
    action, name, arguments = args
    screen = self
    p = self
    while p.parent != nil
      p = p.parent
    end
    closeit = true
    if p.respond_to? action
      arguments ||= []
      arguments = [arguments] unless arguments.is_a?(Array)
      arguments = [screen, name] + arguments
      closeit = p.send(action, *arguments)
      PM.logger.info "#{self.class.name}:#{__method__} action #{action} closeit = #{closeit}"
    end
    close_up if closeit
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

  ##
  # Close up the Menu Screen heirarchy.
  #
  def close_up
    PM.logger.info "#{self.class.name}:#{__method__} #{title}"
    #
    # This iOS seems to miss consecutive closes for some reason.
    # So we us this instance variable to handle calling close_up
    # on the parent, when this window finally goes away. See on_disappear
    # call back.
    @closeUp = true
    #close # this call can be missed for some reason at the top of the chain.
    #parent.close_up if parent
    close({:to_screen => :root})
  end

  def cancel
    PM.logger.info "Cancel"
    p = self
    while p.parent != nil
      PM.logger.info "cancel #{p}"
      p.close
      p = p.parent
    end
    PM.logger.info "Closing #{p}"
    p.close
  end

end