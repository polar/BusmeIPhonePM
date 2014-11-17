class MasterMessageWebScreen < PM::WebScreen

  attr_writer :title

  def title
    @title
  end

  def content
    @content ||= NSURL.URLWithString("http://google.com")
  end

end