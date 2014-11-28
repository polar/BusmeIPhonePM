class UIMarker < UIButton
  include SugarCube::CoreGraphics
  attr_accessor :markerInfo
  attr_reader   :masterMapScreen
  attr_reader   :markerViewController

  def self.markerWith(markerInfo, masterMapScreen)
    marker = self.alloc.init
    marker.initWith(markerInfo, masterMapScreen)
  end

  def masterMapScreen=(ms)
    @masterMapScreen = WeakRef.new(ms)
  end

  def markerViewController=(mvc)
    @markerViewController = mvc
  end

  #          (---------)
  #         =|         |
  #        / (---------)
  #       /
  #      /
  #     -----|----------|
  #   pointer  balloon
  def prepareBackgroundImage(text)
    # Margins within the text Rect
    x_margin = 5
    y_margin = 1

    dynamic_font = self.titleLabel.font
    # We really don't care about the constraintSize just yet
    constraintSize = CGSizeMake(200, 37)
    current_size = text.sizeWithFont(dynamic_font, constrainedToSize:constraintSize, lineBreakMode: NSLineBreakByWordWrapping)

    # These are the images that should be concatenated.
    # They are the same height.
    pointer = UIImage.imageNamed("marker_pointer_unviewed.png")
    balloon = UIImage.imageNamed("map_marker_unviewed.png")

    # We are going to put the text in the balloon, which is at this rect. The
    # balloon should have x_margin space on each horizontal size, and y_margin
    # on each vertical side.

    textRect = Rect(pointer.size.width,
                    pointer.size.height - current_size.height + y_margin * 2,
                    current_size.width + x_margin * 2,
                    pointer.size.height - current_size.height + y_margin * 2)

    # The size of the entire image should be the pointer + the width of the text rect
    # and the height of the images, which are the same height
    img_size = Size(pointer.size.width + textRect.size.width, pointer.size.height)
    pointed = UIImage.canvas(img_size) do |context|
      pointer.drawAtPoint([0,0])
      # We create a stretchable image between the x_margin pixels on each horizontal side
      insets = EdgeInsets(0, 15, 0, 45)
      img = balloon.resizableImageWithCapInsets(insets)
      # We draw that this image, which is the same height as the pointer to cover the textRect
      # This operation is basically filling the image next to the pointer to the desired size
      img.drawInRect(Rect(pointer.size.width, 0, textRect.size.width, pointer.size.height))
    end
    self.setBackgroundImage(pointed, forState: UIControlStateNormal)
    #self.setBackgroundImage(pointed.darken, forState: UIControlStateHighlighted)
    # The text gets drawn centered on the entire size of the button.
    # So, we have to offset the centers with insets so that the
    # center of the text is in the center of the text Rect.
    # The coordinate system is 0,0 at bottom left, so we need to inset right,
    # and up, which means we have a positive left, and a negative top inset.
    # Furthermore the text must be inset by the margins inside the
    # calculated Rect.
    contentRect = Rect([0,0],pointed.size)
    titleCenter = Point [CGRectGetMidX(contentRect), CGRectGetMidY(contentRect)]
    textRectCenter = Point [CGRectGetMidX(textRect), CGRectGetMidY(textRect)]
    top = textRectCenter.y - titleCenter.y + y_margin
    left = textRectCenter.x - titleCenter.x + x_margin
    puts "titleCenter #{titleCenter.inspect} textCenter #{textRectCenter.inspect}"
    puts "top #{-top} left #{left}"
    w = EdgeInsets(-top, left, 0, 0)
    self.titleEdgeInsets = w
    self.size = pointed.size
  end

  def initWith(markerInfo, masterMapScreen)
    self.markerInfo = markerInfo
    self.setTitleColor(:black.uicolor, forState: UIControlStateNormal)
    self.titleLabel.shadowOffset = Size(1,1)
    self.setTitleShadowColor(:gray.uicolor, forState: UIControlStateNormal)
    self.setTitle(markerInfo.title)
    self.addTarget(self, action: "buttonClicked:",  forControlEvents: UIControlEventTouchUpInside)
    self.masterMapScreen = masterMapScreen
    self
  end

  def setTitle(text)
    prepareBackgroundImage(text)
    super.setTitle(text, forState: UIControlStateNormal)
  end

  def buttonClicked(sender)
    puts "#{self.class.name}:#{__method__} #{sender.markerInfo.inspect}"
    self.markerViewController ||= MarkerMessageViewController.new(markerInfo, masterMapScreen)
    markerViewController.display
  end

  def add(view, options = {})
    self.origin = options[:at] if options[:at]
    view.addSubview(self)
  end
end