class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  after_filter :save_last_request

  def save_last_request
    session[:return_to_url] = request.fullpath
  end

  def authenticate!
    redirect_to root_path unless logged_in?
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def parse_json_params(hash, *args)
    args.each do |arg|
      hash[arg] = JSON.parse(hash[arg]) if hash.has_key?(arg)
    end
  end
end
