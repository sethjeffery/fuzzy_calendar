class BackdoorController < ApplicationController
  http_basic_authenticate_with name: ENV["BACKDOOR_NAME"], password: ENV["BACKDOOR_PASSWORD"]

  def enter
    unless Rails.env.production?
      session[:user_id] = User.find(params[:id]).id
      redirect_to root_path
    end
  end
end
