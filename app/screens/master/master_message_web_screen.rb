class MasterMessageWebScreen < PM::WebScreen

  def screen_init(args)
    @title = args[:title]
    @content = NSURL.URLWithString(args[:url]) if args[:url]
    super
  end

  def title
    @title
  end

  def content
    @content ||= NSURL.URLWithString("http://google.com")
  end

end