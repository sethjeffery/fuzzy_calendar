class HomeController < ApplicationController
  include EventsConcern

  def index
    if logged_in?
      @recent_events = recent_events

      render :dashboard
    else
      render :welcome
    end
  end
end
