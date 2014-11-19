NSAttributedString.class_eval do

  def font(font, size = nil)
    if size.nil?
      with_attributes({ NSFontAttributeName => font })
    else
      with_attributes({ NSFontAttributeName => font.fontWithSize(size)})
    end
  end

  def color(color)
    with_attributes({ NSForegroundColorAttributeName => color })
  end
  alias_method :fgColor, :color

  def bgColor(color)
    with_attributes({ NSBackgroundColorAttributeName => color })
  end

  def cgSize(constrain)
    s = SugarCube::CoreGraphics::Size(constrain)
    rect = self.boundingRectWithSize(s, options: NSStringDrawingUsesLineFragmentOrigin, context: nil)
    rect.size
  end

end