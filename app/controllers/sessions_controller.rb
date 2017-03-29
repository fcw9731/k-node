class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      if params[:remember_me]
        # cookies.permanent[:auth_token] = user.auth_token
      else
        # cookies[:auth_token] = user.auth_token
        session[:user_id] = user.id
      end
      redirect_to root_path

    else
      flash[:failure] = "Incorrect password and email combination"
      redirect_to login_path
    end
  end

  def destroy
    session.clear
    # cookies.delete(:auth_token)
    redirect_to root_path
  end

end
