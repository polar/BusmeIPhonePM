class RouteCell < PM::TableViewCell

  class Eatme < UIView
    def viewForBaselineLayout
      subviews.each do |v|
        bottom = v.viewForBaselineLayout
      end
    end
  end

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
  attr_accessor :timesLabel
  attr_accessor :labelFontSize
  attr_accessor :labelFont
  attr_accessor :nameCenterView
  attr_accessor :vidLabelView
  attr_accessor :contentConstraints

  def initWithStyle(style, reuseIdentifier: id)
    super
    # Forces a recalculation
    contentView.bounds = CGRect.new([0,0],[99999,99999])

    # Our relative Size constants
    self.labelFontSize = UIFont.labelFontSize - 4
    self.labelFont = UIFont.systemFontOfSize(labelFontSize)

    # We get rid of these subviews from the standard TableCellView because they have constraints we don't like
    imageView.removeFromSuperview
    textLabel.removeFromSuperview
    detailTextLabel.removeFromSuperview

    # Set up the subviews.
    # icon Route VID Name/Dir Times
    self.iconView = UIImageView.alloc.initWithFrame([[0,0],[0,0]])

    # Route/Dir
    self.nameView = UIView.alloc.initWithFrame([[0,0],[0,0]])
    self.routeNameLabel = UILabel.alloc.initWithFrame([[0,0],[0,0]])
    self.dirLabel = UILabel.alloc.initWithFrame([[0,0],[0,0]])
    dirLabel.textAlignment = NSTextAlignmentRight

    nameView.addSubview(routeNameLabel)
    nameView.addSubview(dirLabel)

    # So we can center Name/Dir vertically
    self.nameCenterView = UIView.alloc.initWithFrame([[0,0],[0,0]])
    nameCenterView.addSubview(nameView)

    self.routeCodeLabel = UILabel.alloc.initWithFrame([[0,0],[0,0]])
    routeCodeLabel.textAlignment = NSTextAlignmentRight
    self.vidLabel = UILabel.alloc.initWithFrame([[0,0],[0,0]])
    self.vidLabelView = UILabel.alloc.initWithFrame([[0,0],[0,0]])
    vidLabelView.addSubview(vidLabel)
    self.timesLabel = UILabel.alloc.initWithFrame([[0,0],[0,0]])
    timesLabel.numberOfLines = 0

    contentView.addSubview(iconView)
    contentView.addSubview(routeCodeLabel)
    contentView.addSubview(vidLabelView)
    contentView.addSubview(nameCenterView)
    contentView.addSubview(timesLabel)

    prepareVid
    prepareNameDir
    prepareNameCenter

    timesLabel.translatesAutoresizingMaskIntoConstraints = false
    iconView.translatesAutoresizingMaskIntoConstraints = false
    routeCodeLabel.translatesAutoresizingMaskIntoConstraints = false
    vidLabelView.translatesAutoresizingMaskIntoConstraints = false
    nameCenterView.translatesAutoresizingMaskIntoConstraints = false

    self.contentConstraints = []
    self
  end

  def prepareNameCenter
    views                                              = {"name" => nameView, "superview" => nameCenterView}
    nameView.translatesAutoresizingMaskIntoConstraints = false
    constraints                                        = []
    constraints << NSLayoutConstraint.constraintsWithVisualFormat("H:[superview]-(<=1)-[name]",
                                                                  options: NSLayoutFormatAlignAllCenterY, metrics: {}, views: views)
    constraints << NSLayoutConstraint.constraintsWithVisualFormat("H:|[name]|",
                                                                  options: 0, metrics: {}, views: views)
    nameCenterView.addConstraints(constraints.flatten)
  end

  def prepareNameDir
    views                                                    = {"title" => routeNameLabel, "dir" => dirLabel}
    routeNameLabel.translatesAutoresizingMaskIntoConstraints = false
    dirLabel.translatesAutoresizingMaskIntoConstraints       = false
    constraints                                              = []
    constraints << NSLayoutConstraint.constraintsWithVisualFormat("V:|[title][dir]|",
                                                                  options: NSLayoutFormatAlignAllLeft, metrics: {}, views: views)
    constraints << NSLayoutConstraint.constraintsWithVisualFormat("H:|[title]|",
                                                                  options: 0, metrics: {}, views: views)
    nameView.addConstraints(constraints.flatten)
  end

  def prepareVid
    views                                              = {"vid" => vidLabel}
    vidLabel.translatesAutoresizingMaskIntoConstraints = false
    constraints                                        = []
    constraints << NSLayoutConstraint.constraintsWithVisualFormat("V:|[vid]|",
                                                                  options: NSLayoutFormatAlignAllLeft, metrics: {}, views: views)
    constraints << NSLayoutConstraint.constraintsWithVisualFormat("H:|[vid]|",
                                                                  options: 0, metrics: {}, views: views)
    vidLabelView.addConstraints(constraints.flatten)
  end

  def will_display
    iconView.image = UIImage.imageNamed(ICONS[journeyDisplay.getIcon-1])
    route = journeyDisplay.route

    text = route.code.attrd
    # Apparently you have to do color before font.
    text = text.fgColor(UIColor.redColor) if journeyDisplay.isNameHighlighted?
    text = text.font(labelFont)
    routeCodeLabel.setAttributedText text
    routeCodeLabel.size = text.cgSize(CGSize.new(100,200))

    if route.isJourney?
      prepareJourney(route)
    else
      prepareRouteDefinition(route)
    end
    contentView.setNeedsLayout
    contentView.layoutIfNeeded
  end

  def prepareJourney(route)
    text = route.name.attrd
    text = text.fgColor(UIColor.redColor) if journeyDisplay.isNameHighlighted?
    text = text.font(labelFont, labelFontSize - 1)
    routeNameLabel.setAttributedText text
    contentView.removeConstraints(contentConstraints)
    contentView.addSubview(vidLabelView) unless vidLabelView.superview

    views       = {"times" => timesLabel, "image" => iconView, "name" => nameCenterView, "code" => routeCodeLabel, "vid" => vidLabelView}
    constraints = []
    constraints << NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[image(16)]-8-[code(30)]-4-[vid(<=30)]-4-[name]-[times(40)]|",
                                                                  options: NSLayoutFormatAlignAllCenterY, metrics: {}, views: views)
    constraints << NSLayoutConstraint.constraintsWithVisualFormat("V:|[name]|",
                                                                  options: NSLayoutFormatAlignAllLeft, metrics: {}, views: views)
    self.contentConstraints = constraints.flatten
    contentView.addConstraints(contentConstraints)

    routeNameLabelSize = text.cgSize(CGSize.new(200, 200))

    text = (route.vid || "1235").attrd
    text = text.fgColor(UIColor.redColor) if journeyDisplay.isNameHighlighted?
    text = text.font(labelFont)
    vidLabel.setAttributedText text

    self.dirLabel.hidden = false
    text                 = route.direction.attrd
    text.fgColor(UIColor.redColor) if journeyDisplay.isNameHighlighted?
    text = text.font(labelFont, labelFontSize - 4)
    dirLabel.setAttributedText text
    dirLabelSize = text.cgSize(CGSize.new(200, 200))

    routeNameLabel.size = routeNameLabelSize
    dirLabel.size       = dirLabelSize

    vidLabel.hidden = false

    puts "NameLabel.size #{routeNameLabelSize.inspect} DirLabel.size #{dirLabelSize.inspect} NameView.size #{nameView.size.inspect}"
    label = route.getStartTime.strftime(time_format)
    label += "\n"
    label += route.getEndTime.strftime(time_format)
    text  = label.attrd
    text  = text.fgColor(UIColor.redColor) if journeyDisplay.isNameHighlighted?
    text  = text.font(labelFont, labelFontSize - 6)
    timesLabel.setAttributedText text
    timesLabel.size = [40, 60]
    timesLabel.fit_to_size(labelFontSize - 4)
    nameCenterView.size.height = nameView.size.height + dirLabel.size.height
  end

  def prepareRouteDefinition(route)
    text               = route.name.attrd
    text               = text.fgColor(UIColor.redColor) if journeyDisplay.isNameHighlighted?
    text               = text.font(labelFont)
    routeNameLabelSize = text.cgSize(CGSize.new(200, 200))
    self.routeNameLabel.setAttributedText text
    # routeNameLabel.frame = [[0,0],routeNameLabelSize]
    routeNameLabel.size = routeNameLabelSize
    self.dirLabel.setAttributedText nil
    self.dirLabel.hidden = true
    self.dirLabel.size   = [0, 0]
    timesLabel.setAttributedText nil
    vidLabel.hidden = true
    contentView.removeConstraints(contentConstraints)
    vidLabelView.removeFromSuperview

    views       = {"times" => timesLabel, "image" => iconView, "name" => nameCenterView, "code" => routeCodeLabel}
    constraints = []
    constraints << NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[image(16)]-8-[code(30)]-8-[name]-[times(40)]|",
                                                                  options: NSLayoutFormatAlignAllCenterY, metrics: {}, views: views)
    constraints << NSLayoutConstraint.constraintsWithVisualFormat("V:|[name]|",
                                                                  options: NSLayoutFormatAlignAllLeft, metrics: {}, views: views)
    self.contentConstraints = constraints.flatten
    contentView.addConstraints(contentConstraints)
    nameCenterView.size.height = nameView.size.height + dirLabel.size.height
  end
end