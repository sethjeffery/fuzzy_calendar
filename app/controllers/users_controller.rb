class UsersController < ApplicationController
  skip_after_filter :save_last_request, only: [:create, :new]
  before_filter :authenticate!, only: [:edit, :update]

  def show
    @user = User.find(params[:id])
    if current_user == @user
      render :edit
    else
      render :show
    end
  end

  def edit
    @user = current_user
    render :edit
  end

  def create
    session[:return_to_url] = params[:redirect_after_login] if params[:redirect_after_login].present?
    @user = User.new user_params

    if @user.save
      auto_login @user, true
      redirect_to session[:return_to_url] || root_path
    else
      render :new
    end
  end

  def update
    @user = current_user
    if @user.update_attributes user_params
      redirect_to me_path, notice: "Well done! You've updated your account."
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :avatar, :email_notifications)
  end
end
