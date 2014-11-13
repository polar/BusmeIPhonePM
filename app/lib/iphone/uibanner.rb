class UIBanner < UIView
  attr_accessor :bannerInfo
  attr_accessor :titleView
  attr_accessor :imageView
  attr_accessor :textView
  attr_accessor :imageUrl

  def viewDidLoad
    PM.logger.info "UIBanner.viewDidLoad"
    Motion::Layout.new do |layout|
      layout.view self
      layout.subviews "image" => imageView, "title" => textView
      layout.vertical "|[image(<=50)]|"
      layout.horizontal "|-5-[image][title]"
    end
    PM.logger.warn "Layout imageView #{imageView}"
    PM.logger.warn "Layout textView #{textView}"
    #self.textView.fit_to_size(12)
    on_tap do
      PM.logger.info "Going to #{bannerInfo.goUrl}"
    end
  end
  def initWith(bannerInfo)
    self.initWithFrame([[0,0], [100,50]])
    self.imageUrl = NSURL.URLWithString(bannerInfo.iconUrl)
    self.bannerInfo = bannerInfo
    self.imageView = UIImageView.alloc.initWithFrame([[0,0],[50, 50]])
    PM.logger.warn "Added imageView #{imageView}"
    self.textView = UILabel.alloc.initWithFrame([[0,0],[50,50]])
    PM.logger.warn "Added textView #{textView} using #{bannerInfo.title}"
    self.textView.text = bannerInfo.title
    PM.logger.warn "Added textView #{textView}"
    self << imageView
    self << textView
    viewDidLoad
    Dispatch::Queue.concurrent.async do
      data = NSData.alloc.initWithContentsOfURL(self.imageUrl)
      image = UIImage.alloc.initWithData(data)
      PM.logger.warn "Got Image from Data #{image}"
      Dispatch::Queue.main.sync do
        PM.logger.warn "PUTING IMAGE IN VIEW"
        self.imageView.size = [image.width, image.height]
        self.imageView.image = image
      end
    end
    PM.logger.info "Returning UIBanner #{self} #{self.frame}"
    self
  end

  def slide_out
    self.animate(1.0) { self.alpha=0; self.origin = [self.origin.x + self.origin.x + self.size.width + 10, self.origin.y]}
  end

  def slide_in
    self.origin = (x = self.origin.x) - self.size.width, self.origin.y
    self.animate(1.0) { self.alpha=1; self.origin = [x, self.origin.y]}
  end
end