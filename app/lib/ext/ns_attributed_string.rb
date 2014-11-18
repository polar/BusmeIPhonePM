NSAttributedString.class_eval do

  def fontSize(size)
    with_attributes({ NSFontAttributeName => font.fontWithSize(size)})
  end

  def font(font)
    with_attributes({ NSFontAttributeName => font })
  end

  def color(color)
    with_attributes({ NSForegroundColorAttributeName => color })
  end
  alias_method :fgColor, :color

  def bgColor(color)
    with_attributes({ NSBackgroundColorAttributeName => color })
  end

  def size(constrain)
    s = SugarCube::CoreGraphics::Size(constrain)
    rect = self.boundingRectWithSize(s, options: NSStringDrawingUsesLineFragmentOrigin, context: nil)
    rect.size
  end

end