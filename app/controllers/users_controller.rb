class UsersController < ApplicationController
  skip_after_filter :save_last_request, only: [:create, :new]

  def show
    @user = User.find(params[:id])
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

  private

  def user_params
    params.require(:user).permit(:name, :email, :password)
  end
end
