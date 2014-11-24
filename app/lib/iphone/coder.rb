Api::Archiver.class_eval do

  def self.xmlParse(data)
    if data.is_a? File
      s = data.read
    else
      s = data
    end
    p s
    rxml = RXMLElement.elementFromXMLString(s, encoding: NSUTF8StringEncoding)
    RaptureXMLTag.new(rxml)
  end
end