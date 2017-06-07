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


        test_url="https://590bc7a2c8f13000014788c5.onlosant.com/users"

        body_hash={"email"=> user_params['email'], "password"=>user_params['password']}

        body_json=body_hash.to_json




        def send_data(test_url,body_hash)

          data=body_hash

          data=data.to_json

          puts "data for json is #{data}"

          url = URI.parse(test_url)

          req = Net::HTTP::Post.new(url.path,{'Content-Type' => 'application/json'})

          req.body = data

          begin

            res = Net::HTTP.new(url.host,url.port).start do |http|

              http.read_timeout=5

              http.request(req)

            end

          rescue Exception

            res = ''

            puts "error:#{$!} at:#{$@}!"

            puts "post to dest failed!"

            return 1
          end

          post_res=res.body

          puts "post result is #{post_res}"

        end

##############################################################################################################################
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
