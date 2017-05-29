class SessionsController < ApplicationController
  require "losant_rest"

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

      #========================================================# 
      # Check authenticate user with Losant
      #========================================================# 
      # begin        
      #   myCredentials = {
      #     "email": params[:email], 
      #     "password": params[:password]
      #   }    
      #   client = LosantRest::Client.new(auth_token: nil, url: "https://api.losant.com")
      #   authStatus = client.auth.authenticate_user(credentials: myCredentials)
      #   if authStatus
      #     session[:losant_auth_token] = authStatus['token']
          redirect_to root_path        
      #   end
      # rescue => e
      #   flash[:failure] = "User Unauthorized with Losant"
      #   redirect_to login_path
      # end
      #========================================================# 
      # End check authenticate user with Losant
      #========================================================#       

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
