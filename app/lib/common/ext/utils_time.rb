
Utils::Time.class_eval do

  def self.parseTimeInZone(str, zone = "America/New_York")
    timeZone = NSTimeZone.timeZoneWithName(zone)

    date_formatter = NSDateFormatter.alloc.init
    date_formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    date_formatter.timeZone = timeZone
    timelit = str.split(":")
    timelit.map {|x| "%02d" % x.to_i }
    if timelit.length < 3
      timelit << "00"
    end
    hms = timelit.join(":")
    tstr = Time.now.strftime("%Y-%m-%dT#{hms}")
    date = date_formatter.dateFromString tstr
    Time.at(date)
  end
end