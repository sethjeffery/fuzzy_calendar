class SessionsController < ApplicationController
  skip_after_filter :save_last_request

  def create
    session[:return_to_url] = params[:redirect_after_login] if params[:redirect_after_login].present?

    if login(session_params[:email], session_params[:password], true)
      redirect_to session[:return_to_url] || root_path
    else
      flash.now[:alert] = "Could not find your user. Please check your email and password."
      render :new
    end
  end

  def destroy
    logout
    session.clear
    redirect_to root_path
  end

  private

  def session_params
    params.require(:session).permit(:email, :password)
  end
end
