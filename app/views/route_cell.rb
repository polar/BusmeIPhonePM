class RouteCell < PM::TableViewCell

  attr_accessor :journeyDisplay
  attr_accessor :time_format

  ICONS = ["route_icon.png",
           "route_icon_active.png",
           "purple_dot_icon.png",
           "blue_circle_icon.png",
           "green_arrow_icon.png",
           "blue_arrow_icon.png",
           "bus_icon_active.png",
           "red_arrow_icon.png"]

  def will_display
   #puts "RouteCell(#{data_cell[:cell_identifier]}) will_display #{journeyDisplay}"
    data_cell[:image] = ICONS[journeyDisplay.getIcon-1]
    set_image
    route = journeyDisplay.route
    if route.isJourney?
      self.textLabel.font = self.textLabel.font.fontWithSize(12)
      if journeyDisplay.isNameHighlighted?
        self.textLabel.color = UIColor.redColor
      else
        self.textLabel.color = UIColor.blackColor
      end
      self.detailTextLabel.hidden = false
      self.detailTextLabel.font = self.detailTextLabel.font.fontWithSize(10)
      direction = route.direction
      label = route.getStartTime.strftime(time_format)
      label += "\n"
      label += route.getEndTime.strftime(time_format)
      data_cell[:subtitle] = direction
      times = UILabel.new(label, UIFont.systemFontOfSize(8), 8)
      times = UILabel.new(label, UIFont.systemFontOfSize(8), 8)
      times.numberOfLines = 0
      f = times.frame
      f.size = [40,20]
      times.frame = f
      times.fit_to_size(12)
      data_cell[:accessory] = {
          :view => times
      }
      set_subtitle
      set_accessory_view
    else
      self.textLabel.font = self.textLabel.font.fontWithSize(12)
      self.detailTextLabel.hidden = true
      data_cell[:accessory] = nil
      set_subtitle
      set_accessory_view
    end
  end
end