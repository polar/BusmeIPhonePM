class LoginForeground < Platform::LoginForeground

  attr_accessor :masterMapScreen
  def initialize(api, masterMapScreen)
    super(api)
    self.masterMapScreen = masterMapScreen
  end

  def presentPasswordLogin(eventData)
    @eventData = eventData
    loginManager = @eventData.loginManager
    login = loginManager.login
    PM.logger.info "#{self.class.name}:#{__method__} #{login.inspect}"

    if login.roleIntent == :driver
      @passwordDriverView ||= BW::UIAlertView.new(
          :title => "Login as Driver",
          :message => "Login with Email",
          :buttons => ["Cancel", "Login"],
          :style => :login_and_password_input,
          :cancel_button_index => 0) do |alertView|

        puts "#{self.class.name}:#{__method__} Register Clicked!"

        if alertView.clicked_button.index == 0
          self.onCancel(eventData)
        else
          loginManager = @eventData.loginManager
          login = loginManager.login
          login.email = @passwordDriverView.textFieldAtIndex(0).text
          login.password = @passwordDriverView.textFieldAtIndex(1).text
          self.onSubmit(@eventData)
        end
      end
      @passwordDriverView.textFieldAtIndex(0).setText(login.email)
      @passwordDriverView.show
    else
      @passwordView ||= BW::UIAlertView.new(
          :title => "Login as Passenger",
          :message => "Login with Email",
          :buttons => ["Cancel", "Login"],
          :style => :login_and_password_input,
          :cancel_button_index => 0) do |alertView|

        puts "#{self.class.name}:#{__method__} Register Clicked!"
        if alertView.clicked_button.index == 0
          onCancel(eventData)
        else
          loginManager = @eventData.loginManager
          login = loginManager.login
          login.email = @passwordView.textFieldAtIndex(0).text
          login.password = @passwordView.textFieldAtIndex(1).text
          self.onSubmit(@eventData)
        end
      end
      @passwordView.textFieldAtIndex(0).setText(login.email)
      @passwordView.show
    end
  end

  attr_accessor :registerView
  def presentRegisterLogin(eventData)
    self.registerView ||= RegisterScreen.new(:nav_bar => true)
    self.registerView.masterController = masterMapScreen.masterController
    self.registerView.loginForeground = self
    self.registerView.eventData = eventData
    masterMapScreen.open registerView
  end

  def presentRegisterLogin1(eventData)
    @eventData = eventData
    loginManager = @eventData.loginManager
    login = loginManager.login
    PM.logger.info "#{self.class.name}:#{__method__} #{login.inspect}"

    if login.roleIntent == :driver
      @registerDriverView ||= BW::UIAlertView.new(
          :title => "Register as Driver",
          :message => "Register with Email and Driver Auth Code",
          :buttons => ["Cancel", "Register"],
          :style => :login_and_password_input,
          :cancel_button_index => 0) do |alertView|

        puts "#{self.class.name}:#{__method__} Register Clicked!"

        if alertView.clicked_button.index == 0
          self.onCancel(eventData)
        else
          loginManager = @eventData.loginManager
          login = loginManager.login
          login.email = @registerDriverView.textFieldAtIndex(0).text
          login.password = @registerDriverView.textFieldAtIndex(1).text
          self.onSubmit(@eventData)
        end
      end
      @registerDriverView.textFieldAtIndex(0).setText(login.email)
      origin = @registerDriverView.textFieldAtIndex(1).frame.origin
      size = @registerDriverView.textFieldAtIndex(1).frame.size
      rect = CGRect.new([origin.x, origin.y + size.height], size)
      @registerDriverView.addSubview(UITextField.alloc.initWithFrame(rect))
      @registerDriverView.show
    else
      @registerView ||= BW::UIAlertView.new(
          :title => "Register as Passenger",
          :message => "Register with Email",
          :buttons => ["Cancel", "Register"],
          :style => :login_and_password_input,
          :cancel_button_index => 0) do |alertView|

        puts "#{self.class.name}:#{__method__} Register Clicked!"

        if alertView.clicked_button.index == 0
          self.onCancel(eventData)
        else
          loginManager = @eventData.loginManager
          login = loginManager.login
          login.email = @registerView.textFieldAtIndex(0).text
          login.password = @registerView.textFieldAtIndex(1).text
          self.onSubmit(@eventData)
        end
      end
      @registerView.textFieldAtIndex(0).setText(login.email)
      @registerView.show
    end
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
        :message => login.roleIntent == :driver ? "Logged in as a driver" : "Logged in as a passenger",
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