UIView.class_eval do

  ##|  SHADOW
  def shadow(shadow=nil)
    if shadow
      {
          opacity: :'shadowOpacity=',
          radius: :'shadowRadius=',
          offset: :'shadowOffset=',
          color: :'shadowColor=',
          path: :'shadowPath=',
      }.each { |key, msg|
        if value = shadow[key]
          if key == :color and [Symbol, Fixnum, NSString, UIImage, UIColor].any?{|klass| value.is_a? klass}
            value = value.uicolor.CGColor
          end
          self.layer.send(msg, value)
          self.layer.masksToBounds = false
          self.layer.shouldRasterize = true
        end
      }
      self
    else
      {
          opacity: self.layer.shadowOpacity,
          radius: self.layer.shadowRadius,
          offset: self.layer.shadowOffset,
          color: self.layer.shadowColor,
          path: self.layer.shadowPath,
      }
    end
  end
end