# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require "memoized.rb"
class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
   
  def create_admin_session(admin)
    session[:admin] = { :user => admin, :session_start_time => Time.now }
  end

  def clear_admin_session
    session[:admin] = nil
  end

  def current_admin
    session[:admin][:user] if session[:admin]
  end

  def memoized_object(object, method)
    if session[:memoized_object].nil?
      session[:memoized_object] =  Memoized.memoize(object, method)
      session[:memoized_object]
    else
      session[:memoized_object]
    end 
  end

  private

  def admin_logged_in?
    if current_admin.nil?
      flash[:notice] = "Please login to access admin console"
      redirect_to login_url
    end
  end



end
