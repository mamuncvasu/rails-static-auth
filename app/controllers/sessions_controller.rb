class SessionsController < ApplicationController
  skip_before_action :authorize
  def new
  end

  def create
    user = User.find_by(email: params[:email])

    if user.try(:authenticate, params[:password])
      session[:user_id] = user.id
      redirect_to admin_url
    else
      redirect_to   login_url, alert:  'Invalid user/password'
    end
  end

  def destroy
    params[:user_id] = nil
    redirect_to login_path, notice: 'Logged Out'
  end
end
