class JourneySelectionScreen < PM::TableScreen
  attr_reader :journeys
  attr_accessor :masterController
  attr_accessor :parent

  title "Reporting"

  def location=(loc)
    @location = loc
    if masterController
      self.journeys = masterController.journeySelectionPostingController.selectJourneys(loc)
    end
  end

  def journeys=(jds)
    @journeys = jds
    update_table_data
  end

  def table_data
      # This method gets called on_load before we are setup.
      if masterController && journeys
        data = []
        journeys.each do |jd|
          data << {
              #:title => jd.route.name,
              :action => :hit,
              :long_press_action => :longhit,
              :arguments => jd,
              :cell_class => RouteCell,
              :cell_style => UITableViewCellStyleSubtitle,
              :style => {
                  :journeyDisplay => jd,
                  :time_format => masterController.master.time_format
              }
          }
        end
      else
        data = []
      end

      [{
           :title => "Select the vehicle you are on",
           :cells => data
       }]
  end

  def close_up
    PM.logger.warn "#{self.class.name}:#{__method__} : #{parent.inspect}"
    # if parent.is_a?(MenuScreen)
    #   parent.close_up
    # end
    close({:to_screen => :root})
  end

  def hit(jd)
    PM.logger.warn "#{self.class.name}:#{__method__} : #{jd.route.name}"
    loc = masterController.locationController.currentLocation
    if loc
      dist = Platform::GeoPathUtils.offPath(jd.route.getPath(0), loc)
      if dist > masterController.api.offRouteDistanceThreshold
        @distanceAlertView = BW::UIAlertView.default(
            :title => "Distance Too Far",
            :message => "You are currently #{dist} feet from the route. Do you want to post for this route",
            :buttons => ["Cancel", "Yes"]
        ) do |alert|
          # I'm really not sure if jd will be available on this callback.
          alertView(alert,  alert.clicked_button.index, jd)
        end
        @distanceAlertView.show
      else
        if login = masterController.api.loggedIn?
          evd = Platform::JourneyEventData.new
          evd.route = jd.route
          evd.role = login.roleIntent
          masterController.api.bgEvents.postEvent("JourneyStartPosting", evd)
          close_up
        else
          @notLoggedInAlertView = BW::UIAlertView.default(
               :title => "Not Logged In",
               :message => "You are not currently logged in. Try again",
               :buttons => ["OK"]
          )
          @notLoggedInAlertView.show
          3.seconds.later do
            if @notLoggedInAlertView
              @notLoggedInAlertView.dismissWithClickedButtonIndex(0, animated: true)
              @notLoggedInAlertView = nil
            end
          end
          close_up
        end
      end
    end
  end

  def alertView(alertView, index, jd)
    PM.logger.warn "#{self.class.name}:#{__method__} : #{index}"
    if alertView == @distanceAlertView
      if index == 1
        if login = masterController.api.loggedIn?
          evd = Platform::JourneyEventData.new
          evd.route = jd.route
          evd.role = login.roleIntent
          masterController.api.bgEvents.postEvent("JourneyStartPosting", evd)
        else
          @notLoggedInAlertView = BW::UIAlertView.default(
              :title => "Not Logged In",
              :message => "You are not currently logged in. Try again",
              :buttons => ["OK"]
          )
          @notLoggedInAlertView.show
          3.seconds.later do
            if @notLoggedInAlertView
              @notLoggedInAlertView.dismissWithClickedButtonIndex(0, animated: true)
              @notLoggedInAlertView = nil
            end
          end
        end
      end
      @distanceAlertView = nil
    end
    if alertView == @notLoggedInAlertView
      @notLoggedInAlertView = nil
    end
    close_up
  end

  def longHit(jd)
    PM.logger.warn "#{self.class.name}:#{__method__} : #{jd.route.name}"
  end
end