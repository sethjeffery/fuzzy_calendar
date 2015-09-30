class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  after_filter :save_last_request

  def save_last_request
    session[:last_request] = request.fullpath
  end

  def authenticate!
    redirect_to login_path unless logged_in?
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
end
