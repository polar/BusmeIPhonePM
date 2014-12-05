Time.class_eval do

  alias_method :strftime1, :strftime

  def strftime(fmt)
    default_offset = NSTimeZone.defaultTimeZone.secondsFromGMT
    ntime = self - (self.gmt_offset - default_offset)
    ntime.strftime1(fmt)
  end
end