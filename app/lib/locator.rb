class Icon
  attr_accessor :image
  attr_accessor :hotspot

  def initialize(image, hotpot = nil)
    if hotspot.nil?
      self.hotspot = [image.size.width/2, image.size.height/2]
    end
    if hotspot.is_a? Array
      self.hotspot = CGPointMake(hotspot[0], hotspot[1])
    end
    self.image = image
  end

  def hotspot= hp
    if image && (hp.nil? || hp == :center)
      @hotspot = [image.size.width/2, image.size.height/2]
    end
    if hp.is_a? Array
      @hotspot = CGPointMake(hp[0], hp[1])
    end
    if @hotspot.nil? && !hp.is_a?(CGPoint)
      @hotspot = CGPointMake(hp.x, hp.y)
    end
  end

  def toView(at)
    UIImageView.alloc.initWithImage(image).tap do |view|
      view.position = at
    end
  end

  def scale_to(size)
    if size.is_a? Array
      size = CGSizeMake(size[0], size[1])
    end
    matrix = CGAffineTransformMakeScale(size.width, size.height)
    hp = CGPointApplyAffineTransform(hotspot, matrix)
    Icon.new(image.scale_to(size),hp)
  end

  def scale_by(scale)
    scale_to([scale*image.size.width, scale*image.size.height])
  end
end

class Locator
  attr_accessor :image
  attr_accessor :arrow
  attr_accessor :hotspot

  def direction(d)
    icon = image.flip(:horizontal).merge(arrow.rotate(d))
    matrix = CGAffineTransformMakeRotation(d)
    hp = CGPointApplyAffineTransform(hotspot, matrix)
    Icon.new(icon, hp)
  end

  @@icons = {}
  def self.get(name)
    @@icons[name] ||= Locator.new.tap do |loc|
      loc.image = UIImage.imageNamed("#{name}_button.png")
      loc.arrow = UIImage.imageNamed("#{name}_arrow.png")
      loc.hotspot = CGPointMake(22, 30)
    end
  end
end