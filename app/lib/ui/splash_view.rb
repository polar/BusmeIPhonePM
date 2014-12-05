class SplashView
  attr_accessor :imageName
  attr_accessor :image
  attr_accessor :imageView
  attr_accessor :screen

  def initialize(args = {})
    self.imageName = args[:imageName]
    self.screen = WeakRef.new args[:screen]
    screen.navigationController.view.subviews.each do |view|
      if view.is_a? UINavigationBar
        self.nav_bar_view = view
        view.setHidden true
      end
    end
  end

  attr_accessor :nav_bar_view

  def onView(view)
    PM.logger.error "#{self.class.name}:#{__method__}"
    AppDelegate.status_bar(false)
    AppDelegate.apply_status_bar
    if nav_bar_view
      nav_bar_view.setHidden true
    end

    self.image = UIImage.imageNamed(imageName).scale_to(UIScreen.mainScreen.bounds.size)

    self.imageView = UIImageView.alloc.initWithImage(image)
    view.addSubview(imageView)
    view.bringSubviewToFront(imageView)

    UIView.transitionWithView(view, duration:10.0,
                              options: UIViewAnimationOptionTransitionNone,
                              animations: lambda {imageView.alpha = 0},
                              completion: lambda {|f| finish(f)})

  end

  def finish(finished)
    imageView.removeFromSuperview
    self.imageView = nil
    UIApplication.sharedApplication.setStatusBarHidden(false, animated:false)
    if nav_bar_view
      nav_bar_view.setHidden false
    end
    AppDelegate.status_bar(true, { :animation => :fade })
    AppDelegate.apply_status_bar
  end


end