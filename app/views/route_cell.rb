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

  attr_accessor :nameView
  attr_accessor :iconView
  attr_accessor :routeNameLabel
  attr_accessor :dirLabel
  attr_accessor :routeCodeLabel
  attr_accessor :vidLabel

  def initWithStyle(style, reuseIdentifier: id)
    super
    imageView.removeFromSuperview
    textLabel.removeFromSuperview
    detailTextLabel.removeFromSuperview
    self.iconView = UIImageView.alloc.initWithFrame([[0,0],[0,0]])
    self.nameView = UIView.alloc.initWithFrame([[0,0],[0,0]])
    self.routeNameLabel = UILabel.alloc.initWithFrame([[0,0],[0,0]])
    self.dirLabel = UILabel.alloc.initWithFrame([[0,0],[0,0]])
    nameView.addSubview(routeNameLabel)
    nameView.addSubview(dirLabel)
    contentView.addSubview(iconView)
    contentView.addSubview(nameView)
    self.routeCodeLabel = UILabel.alloc.initWithFrame([[0,0],[0,0]])
    self.vidLabel = UILabel.alloc.initWithFrame([[0,0],[0,0]])
    contentView.addSubview(routeCodeLabel)
    contentView.addSubview(vidLabel)
    routeCodeLabel.font = self.routeCodeLabel.font.fontWithSize(10)
    vidLabel.font = self.vidLabel.font.fontWithSize(10)

    Motion::Layout.new do |layout|
      layout.view self.nameView
      layout.subviews "title" => routeNameLabel, "dir" => dirLabel
      layout.vertical "|[title][dir]|"
      layout.horizontal "|[title]-|"
      layout.horizontal "|[dir]-|"
    end

    Motion::Layout.new do |layout|
      layout.view self.contentView
      layout.subviews "image" => iconView, "name" => nameView, "code" => routeCodeLabel, "vid" => vidLabel
      layout.vertical "|-[image(16)]-|"
      layout.vertical "|[code]|"
      layout.vertical "|[vid]|"
      layout.vertical "|[name]|"
      layout.horizontal "|-8-[image(16)]-8-[code(30)]-8-[vid(20)]-8-[name]|"
    end
    self
  end

  def will_display
    puts "RouteCell(#{data_cell[:cell_identifier]}) will_display #{journeyDisplay}"
    iconView.image = UIImage.imageNamed(ICONS[journeyDisplay.getIcon-1])
    route = journeyDisplay.route
    text = route.code.attrd(NSFontAttributeName => self.routeNameLabel.font.fontWithSize(12))
    rect = text.boundingRectWithSize(CGSizeMake(100,20), options: NSStringDrawingUsesLineFragmentOrigin, context: nil)
    routeCodeLabel.setAttributedText text
    routeCodeLabel.size = rect.size
    text = route.name.attrd(NSFontAttributeName => self.routeNameLabel.font.fontWithSize(12))
    rect = text.boundingRectWithSize(CGSizeMake(100,20), options: NSStringDrawingUsesLineFragmentOrigin, context: nil)
    routeNameLabel.setAttributedText text
    routeNameLabel.size = rect.size
    puts "RouteCodeLabel.size #{routeCodeLabel.size.inspect} RouteNameLabel.size #{routeNameLabel.size.inspect}"
    if route.isJourney?
      vidLabel.text = route.vid
      #self.routeNameLabel.font = self.routeNameLabel.font.fontWithSize(12)
      if journeyDisplay.isNameHighlighted?
        self.routeNameLabel.color = UIColor.redColor
      else
        self.routeNameLabel.color = UIColor.blackColor
      end
      self.dirLabel.hidden = false
      self.dirLabel.font = self.dirLabel.font.fontWithSize(10)
      dirLabel.text = route.direction
      text = route.direction.attrd(NSFontAttributeName => self.routeNameLabel.font.fontWithSize(10))
      rect = text.boundingRectWithSize(CGSizeMake(100,20), options: NSStringDrawingUsesLineFragmentOrigin, context: nil)
      dirLabel.setAttributedText text
      dirLabel.size = rect.size
      label = route.getStartTime.strftime(time_format)
      label += "\n"
      label += route.getEndTime.strftime(time_format)
      #data_cell[:subtitle] = direction
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
      #set_subtitle
      set_accessory_view
    else
      self.routeNameLabel.text = route.name
      self.routeNameLabel.font = self.routeNameLabel.font.fontWithSize(12)
      self.dirLabel.hidden = true
      data_cell[:accessory] = nil
      #set_subtitle
      set_accessory_view
    end
  end
end