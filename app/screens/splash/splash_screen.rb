class SplashScreen < PM::Screen
  attr_accessor :imageName
  attr_accessor :image
  attr_accessor :imageView

  def self.new(args = {})
    s = self.alloc.init
    s.imageName = args[:imageName]
    s.screen_init(args)
    s
  end

  def on_init
    img = UIImage.imageNamed(imageName)
    #PM.logger.error "Scaling Splash #{imageName} to #{img.size.inspect} to #{UIScreen.mainScreen.bounds.size.inspect}"
    self.image = UIImage.imageNamed(imageName).scale_to(UIScreen.mainScreen.bounds.size)

    self.imageView = UIImageView.alloc.initWithImage(image)
    view.addSubview(imageView)
    view.bringSubviewToFront(imageView)
  end




  end