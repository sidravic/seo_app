class AdminController < ApplicationController
 before_filter :admin_logged_in?, :only=>[:show] 

  def login
    unless current_admin
      @admin = Admin.new
    else
      redirect_to admin_url(current_admin.id)
    end
  end

  def authenticate
    @admin =  Admin.new(params[:admin])
    if admin =  @admin.authenticate_admin
      create_admin_session(admin)
      admin.update_last_access_at
      redirect_to admin_url(admin.id)
    else
      flash[:error]  = "Invalid username or password"
      render :action => :login
    end
  end

  def show
    if admin_logged_in?
      @admin = current_admin
    end
  end

  def logout
      admin = current_admin
      clear_admin_session
      flash[:notice] = "You have successfully logged out"
      redirect_to login_url   
  end


end
