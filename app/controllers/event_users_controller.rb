class EventUsersController < ApplicationController
  before_filter :find_event

  private

  def find_event
    @event = Event.find(params[:event_id])
  end
end
