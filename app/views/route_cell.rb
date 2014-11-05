class RouteCell < PM::TableViewCell

  attr_accessor :journeyDisplay

  ICONS = ["route_icon.png",
           "route_icon_active.png",
           "purple_dot_icon.png",
           "blue_circle_icon.png",
           "green_arrow_icon.png",
           "blue_arrow_icon.png",
           "bus_icon_active.png"]

  def will_display
    puts "RouteCell(#{data_cell[:cell_identifier]}) will_display #{journeyDisplay}"
    data_cell[:image] = ICONS[journeyDisplay.getIcon-1]
    set_image
    route = journeyDisplay.route
    if route.isJourney?
      direction = route.direction
      label = route.startTime.strftime("%H:%S %P")
      label += "\n"
      label += route.endTime.strftime("%H:%S %P")
      data_cell[:subtitle] = direction
      times = UILabel.new(label, UIFont.systemFontOfSize(8), 8)
      times.numberOfLines = 0
      data_cell[:accessory] = {
          :view => times
      }
      set_subtitle
      set_accessory_view
    else
      label = Time.now.strftime("%H:%S %P")
      label += "\n"
      label += Time.now.strftime("%H:%S %P")
      data_cell[:subtitle] = "Eatme Here"
      times = UILabel.new(label, UIFont.systemFontOfSize(8), 8)
      times.numberOfLines = 0
      data_cell[:accessory] = {
          :view => times
      }
      set_subtitle
      set_accessory_view
    end
  end
end