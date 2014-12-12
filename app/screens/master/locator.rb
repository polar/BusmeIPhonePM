
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
  def self.get(name, reported = false)
    @@icons["#{name}#{reported}"] ||= Locator.new.tap do |loc|
      loc.image = reported ? UIImage.imageNamed("#{name}_yellow_button.png") : UIImage.imageNamed("#{name}_button.png")
      loc.arrow = UIImage.imageNamed("#{name}_arrow.png")
      loc.hotspot = CGPointMake(22, 30)
    end
  end
end