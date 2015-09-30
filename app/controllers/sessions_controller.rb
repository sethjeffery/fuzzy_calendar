class SessionsController < ApplicationController
  skip_after_filter :save_last_request

  def destroy
    logout
    session.clear
    redirect_to root_path
  end
end
