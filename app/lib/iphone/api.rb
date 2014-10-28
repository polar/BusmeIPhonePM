module IPhone
  class Api < Platform::PlatformApi
    def initialize(master)
      super(IPhone::Http::HttpClient.new, master.slug, master.apiUrl, "iPhone", "0.1.0")
      self.bgEvents = ::Api::BuspassEventDistributor.new(:name => "BGEvents:#{master.slug}", :queue => IPhoneQ.new)
      self.uiEvents = ::Api::BuspassEventDistributor.new(:name => "UIEvents:#{master.slug}", :queue => IPhoneQ.new)
    end

    def xmlParse(entity)
      s = entity.getContent.to_s
      rxml = RXMLElement.elementFromXMLString(s, encoding: NSUTF8StringEncoding)
      RaptureXMLTag.new(rxml)
    end

  end
end