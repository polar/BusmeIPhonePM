module IPhone
  class FGBusmeLocatorController < Platform::FGBusmeLocatorController
    attr_accessor :discoverScreen

    def initialize(guts, discoverScreen)
      super(guts.discoverApi)
      self.discoverScreen = discoverScreen
      discoverScreen.controller = self
    end

    def performGet(lon, lat, buf)
      alertView = UIAlertView.alloc.initWithTitle("Looking For Bus Server",
                                                  message: nil,
                                                  delegate:nil,
                                                  cancelButtonTitle: nil,
                                                  otherButtonTitles: nil)
      indicator = UIActivityIndicatorView.alloc.initWithActivityIndicatorStyle(UIActivityIndicatorViewStyleGray)
      indicator.startAnimating
      alertView.setValue(indicator, forKey: "accessoryView")
      alertView.show
      super(alertView, lon, lat, buf)
    end

    # Called from UI
    def performDiscover(lon, lat, buf)
      super(nil, lon, lat, buf)
    end

    def performSelect(loc)
      super(nil, loc)
    end

    # Called from UI
    def onDiscover(eventData)
      masters = eventData.masters
      discoverScreen.addMasters(masters) if masters
    end

    # Called from UI
    def onGet(eventData)
      alertView = eventData.uiData
      alertView.dismissWithClickedButtonIndex(0, animated: true)
      #performDiscover(eventData.lon, eventData.lon, eventData.buf)
    end

  end
end