module IPhone
  class DiscoverApi < ::Api::DiscoverAPIVersion1
    def initialize(httpClient = nil, url)
      super(httpClient || IPhone::Http::HttpClient.new, url)
    end

    def xmlParse(data)
      s = data.getContent.to_s
      rxml = RXMLElement.elementFromXMLString(s, encoding: NSUTF8StringEncoding)
      RaptureXMLTag.new(rxml)
    end

  end
end