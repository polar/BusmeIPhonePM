Time.class_eval do

  def self.parse(str)
    date_formatter = NSDateFormatter.alloc.init
    date_formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"

    date = date_formatter.dateFromString "2010-12-15T13:16:45Z"
    Time.at(date)
  end
end