
class Locator
  attr_accessor :image
  attr_accessor :arrow
  attr_accessor :hotspot

  def direction(d)
    if arrow
      icon = image.flip(:horizontal).merge(arrow.rotate(d))
      matrix = CGAffineTransformMakeRotation(d)
      hp = CGPointApplyAffineTransform(hotspot, matrix)
      Icon.new(icon, hp)
    else
      Icon.new(image, hotspot)
    end
  end

  def icon
    Icon.new(image, hotspot)
  end

  @@icons = {}
  def self.getArrow(name, reported = false)
    @@icons["#{name}#{reported}"] ||= Locator.new.tap do |loc|
      loc.image = reported ? UIImage.imageNamed("#{name}_yellow_button.png")
                           : UIImage.imageNamed("#{name}_button.png")
      loc.arrow = UIImage.imageNamed("#{name}_arrow.png")
      loc.hotspot = CGPointMake(22, 30)
    end
  end

  def start(measure)
    Icon.new(image.opacity(measure), hotspot)
  end

  def self.getStarting(color)
    @@icons["#{color}"] ||= Locator.new.tap do |loc|
      loc.image = UIImage.imageNamed("#{color}_button.png")
      loc.arrow = UIImage.imageNamed("#{color}_dot.png")
      loc.hotspot = CGPointMake(22, 30)
    end
  end

  def self.getReporting(type)
    @@icons["#{type}"] ||= Locator.new.tap do |loc|
      loc.image = UIImage.imageNamed("#{type}_icon.png")
      loc.hotspot = CGPointMake(22, 30)
    end
  end
end