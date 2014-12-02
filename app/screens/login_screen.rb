class LoginScreen < PM::FormScreen

  title "Busme"

  attr_reader   :masterController
  attr_accessor :loginForeground
  attr_reader   :eventData
  attr_reader   :loginManager
  attr_reader   :login

  def masterController=(mc)
    @masterController = mc
    self.title = "#{masterController.master.name}"
  end

  def eventData=(evd)
    @eventData = evd
    self.loginManager = evd.loginManager
  end

  def loginManager=(lm)
    @loginManager = lm
    self.login = lm.login
  end

  def login=(login)
    @login = login
    update_form_data
  end

  def on_init
    set_nav_bar_button(:right, {:title => "Login", :action => :performLogin})
  end

  def email_data
    [{
        :name  => :email,
        :title => "Email",
        :type  => :email,
        :value => (login ? login.email : "")
    }]
  end

  def password_data
    [{
         :name  => :password,
         :title => "Password",
         :type  => :password,
         :value => ""
     }]
  end

  def form_data
    [{
         :title => "#{masterController.master.name} Account",
         :cells => email_data + password_data
     }]
  end

  def performLogin
    dismiss_keyboard
    form = render_form
    PM.logger.warn "#{self.class.name} #{form.inspect}"
    if login
      login.email = form[:email]
      login.password = form[:password]
      loginForeground.onSubmit(self.eventData)
    end
    self.close
  end

  def on_disappear
    parent_screen.close_up if parent_screen.is_a?(MenuScreen)
  end
end