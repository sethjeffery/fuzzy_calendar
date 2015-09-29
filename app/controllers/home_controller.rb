class HomeController < ApplicationController
  def index
    if logged_in?
      render :dashboard
    else
      render :welcome
    end
  end
end
