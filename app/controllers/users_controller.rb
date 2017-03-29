class UsersController < ApplicationController

  def new
    @user = User.new
  end

  def dashboard
    @user = User.find_by(id: params[:id])
  end

  def create
    @user = User.new(user_params)
    if @user.save
      # mail = UserMailer.new_user(@user)
      # mail.deliver_later
      redirect_to root_path
    else
      @errors = @user.errors.messages
      render :action => 'new'
    end
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
