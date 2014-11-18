

class StringIO
  def initialize(str = "")
    @string = NSMutableString.stringWithCapacity(100)
    @string.setString(str) if str
    @string
  end

  def write(str)
    if str && !str.empty?
      @string.appendString(str)
    end
  end

  def string
    @string
  end

  def to_s
    @string
  end
end