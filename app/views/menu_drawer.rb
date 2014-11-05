class NavigationScreen < ProMotion::TableScreen

  def table_data
    [{
         title: nil,
         cells: [{
                     title: 'OVERWRITE THIS METHOD',
                     action: :swap_center_controller,
                     arguments: Discover1Screen
                 }]
     }]
  end

  def swap_center_controller(screen_class)
    app_delegate.menu.center_controller = screen_class
  end

end

class MenuDrawer < PM::Menu::Drawer

  def setup
    self.center = MenuScreen.new(nav_bar: true)
    self.left = NavigationScreen.new
    #self.to_show = [:tap_nav_bar, :pan_nav_bar]
    self.max_left_width = 250
  end
end
