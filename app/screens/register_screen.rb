class RegisterScreen < PM::FormScreen

  title "Busme"

  attr_reader   :masterController
  attr_accessor :loginForeground
  attr_reader   :eventData
  attr_reader   :loginManager
  attr_reader   :login

  def masterController=(mc)
    @masterController = mc
    self.title = "Busme #{masterController.master.name}"
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
    set_nav_bar_button(:right, {:title => "Register", :action => :register})
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
     }, {
         :name  => :passwordConfirmation,
         :title => "Confirm",
         :type  => :password,
         :value => ""
     }]
  end

  def auth_code_data
    [{
         :name  => :auth_code,
         :title => "Driver Auth Code",
         :type  => :text,
         :value => ""
     }]
  end

  def form_data
    [{
         :title => (login && login.roleIntent == :driver ? "Account For Driver" : "Account"),
         :cells => email_data + password_data + (login && login.roleIntent == :driver ? auth_code_data : [])
     }]
  end

  def register
    dismiss_keyboard
    form = render_form
    PM.logger.warn "#{self.class.name} #{form.inspect}"
    if login
      login.email = form[:email]
      login.password = form[:password]
      login.passwordConfirmation = form[:passwordConfirmation]
      login.driverAuthCode = form[:auth_code]
      loginForeground.onSubmit(self.eventData)
    end
    self.close
  end
end