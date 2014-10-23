module IPhone
  class Api < Platform::PlatformApi
    def initialize
      super
      self.http_client = IPhone::Http::HttpClient.new
    end
  end
end