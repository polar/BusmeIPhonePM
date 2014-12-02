class LoginManager < Api::LoginManager

  attr_accessor :screen
  def initialize(api, login, screen)
    super(api, login)
    self.screen = screen
  end

  def close_up
    screen.close_up if screen.is_a?(MenuScreen)
  end
end