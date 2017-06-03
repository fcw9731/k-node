class UsersController < ApplicationController
  require "losant_rest"

  def new
    @user = User.new
  end

  def dashboard
    @user = User.find_by(id: params[:id])
  end

  def create
    @user = User.new(user_params)
    # if @user.save
      # mail = UserMailer.new_user(@user)
      # mail.deliver_later

      #========================================================# 
      # Save user to Losant
      #========================================================# 
      begin        
        _user_info = {
          "email": user_params['email'],
          "firstName": user_params['first_name'],
          "lastName": user_params['last_name'],
          "password": user_params['password'],
          "userTags": {            
            "phone": user_params['phone']
          }
        }    
        client = LosantRest::Client.new(auth_token: ENV['LOSANT_API_TOKEN'], url: "https://api.losant.com")                
        registerStatus = client.experience_users.post(applicationId: ENV['LOSANT_APP_ID'], experienceUser: _user_info)        
        if registerStatus
          # Only save user to local DB, after saved on Losant
          @user.save

          #Redirect page
          redirect_to root_path
        end
      rescue => e
        flash[:failure] = e        
        render :action => 'new'
      end
      #========================================================# 
      # End Save user to Losant
      #========================================================#  
    # else
    #   @errors = @user.errors.messages
    #   render :action => 'new'
    # end
  end

  def show
    @user = User.find_by(id: params[:id])
  end

  def edit
    @user = User.find_by(id: params[:id])
  end

  def update
    @user = User.find_by(id: params[:id])

    if @user.update_attributes(user_params)
      redirect_to user_path(@user)
    else
      render :action => 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :type, :phone)
  end

end
