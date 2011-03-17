require "java"
require "observer"
require File.dirname(__FILE__) + "/../lib/glimmer"

#Presents login screen data
class LoginPresenter
  
  attr_accessor :user_name
  attr_accessor :password
  attr_accessor :status
  
  def initialize
    @user_name = ""
    @password = ""
    @status = "Logged Out"
  end
  
  def status=(status)
    @status = status
    
    #TODO add feature to bind dependent properties to master property
    notify_observers("logged_in") 
    notify_observers("logged_out")
  end
  
  def logged_in
    self.status == "Logged In"
  end
  
  def logged_out
    !self.logged_in
  end
  
  def login
    self.user_name = ""
    self.password = ""
    self.status = "Logged In"
  end
  
  def logout
    self.user_name = ""
    self.password = ""
    self.status = "Logged Out"
  end
  
end

#Login screen
class Login
  include_package 'org.eclipse.swt'
  include_package 'org.eclipse.swt.layout'
  
  include Glimmer
  
  def launch
    presenter = LoginPresenter.new
    @shell = shell {
      text "Login"
      composite { 
        layout GridLayout.new(2, false) #two columns with differing widths
        
        label { text "Username:" } # goes in column 1
        text {                     # goes in column 2
          text bind(presenter, :user_name) 
          enabled bind(presenter, :logged_out)
        } 
        
        label { text "Password:" } 
        text(:password, :border) {
          text bind(presenter, :password) 
          enabled bind(presenter, :logged_out)
        }
        
        label { text "Status:" } 
        label { text bind(presenter, :status) }
        
        button { 
          text "Login"
          enabled bind(presenter, :logged_out)
          on_widget_selected { presenter.login }
        }
        
        button { 
          text "Logout"
          enabled bind(presenter, :logged_in)
          on_widget_selected { presenter.logout }
        }
      }
    }
    @shell.open
  end
end

Login.new.launch
