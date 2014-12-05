class LoginForeground < Platform::LoginForeground

  attr_accessor :masterMapScreen
  def initialize(api, masterMapScreen)
    super(api)
    self.masterMapScreen = masterMapScreen
  end

  attr_accessor :loginView
  def presentPasswordLogin(eventData)
    self.loginView ||= LoginScreen.new(:nav_bar => true)
    self.loginView.masterController = masterMapScreen.masterController
    self.loginView.loginForeground = self
    self.loginView.eventData = eventData
    masterMapScreen.open loginView
  end

  attr_accessor :registerView
  def presentRegisterLogin(eventData)
    self.registerView ||= RegisterScreen.new(:nav_bar => true)
    self.registerView.masterController = masterMapScreen.masterController
    self.registerView.loginForeground = self
    self.registerView.eventData = eventData
    masterMapScreen.open registerView
  end

  def presentError(eventData)
    @eventData = eventData
    loginManager = @eventData.loginManager
    login = loginManager.login
    PM.logger.info "#{self.class.name}:#{__method__} #{login.inspect}"
      @errorView = BW::UIAlertView.new(
          :title => "Login Error",
          :message => eventData.loginManager.login.status,
          :buttons => ["OK"],
          :cancel_button_index => 0) do

        puts "#{self.class.name}:#{__method__} OK Clicked!"
        if @errorView
          onContinue(@eventData)
        end
        @errorView = nil
      end
      @errorView.show
      3.seconds.later do
        if @errorView
          @errorView.dismissWithClickedButtonIndex(0, animated: true)
          onContinue(@eventData)
          @errorView = nil
        end
      end
  end

  def presentConfirmation(eventData)
    @eventData = eventData
    loginManager = @eventData.loginManager
    login = loginManager.login
    PM.logger.info "#{self.class.name}:#{__method__} #{login.inspect}"
      @confirmView = BW::UIAlertView.new(
        :title => "Logged In",
        :message => "Logged in as #{login.email}",
        :buttons => ["OK"],
        :cancel_button_index => 0) do
        puts "Logged In OK Clicked."
        if @confirmView
          onContinue(@eventData)
        end
        @confirmView = nil
      end
      @confirmView.show
      3.seconds.later do
        if @confirmView
          @confirmView.dismissWithClickedButtonIndex(0, animated: true)
          onContinue(@eventData)
          @confirmView = nil
        end
      end
  end
end