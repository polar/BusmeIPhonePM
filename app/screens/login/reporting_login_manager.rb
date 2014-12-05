class ReportingLoginManager < Api::LoginManager

  def onScreen(screen)
    if login.roleIntent == :driver && !login.roles.include?(:driver)
      @notAuthorizedView = BW::AlertView.new(
          :title => "Not Authorized",
          :message => "You are not authorized as a driver, you are posting as a passenger")
      @notAuthorizedView.show
      2.seconds.later do
        if @notAuthorizedView
          @notAuthorizedView.dismissWithButtonIndex(0)
          @notAuthorizedView = nil
        end
      end
    else
      showSelections(screen)
    end

  end

  def showSelections(screen)
    masterController = screen.masterController
    screen.journeySelectionScreen ||= JourneySelectionScreen.new(:nav_bar => true)

    screen.journeySelectionScreen.masterController = masterController
    screen.journeySelectionScreen.location         = masterController.locationController.currentLocation

    journeys = screen.journeySelectionScreen.journeys

    if journeys.empty?
      alertView = BW::UIAlertView.new(:title => "No suitable journeys",
                                      :message => "Cannot find a suitable journey close to your location")
      alertView.show
    else
      screen.open screen.journeySelectionScreen
    end
  end
end