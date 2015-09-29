class EventsController < ApplicationController
  before_filter :fetch_event, only: [:show, :rsvp, :update]

  def index
    @events = Event.all
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new event_params
    @event.creator = current_user

    if @event.save
      redirect_to @event
    else
      render :new
    end
  end

  def rsvp
    @event_user = @event.event_users.find_by_user_id(current_user.id) || @event.event_users.create(user_id: current_user.id)

    dates = JSON.parse(rsvp_params[:dates])
    dates.each do |date, options|
      event_user_time = @event_user.times.find_by_time(date.to_datetime) || @event_user.times.new(time: date.to_datetime)
      event_user_time.favorite = !!options["favorite"]
      event_user_time.save!
    end

    @event_user.times.where("time NOT IN (?)", dates.keys.map(&:to_datetime)).delete_all
    @event_user.save

    redirect_to @event
  end

  private

  def rsvp_params
    params.require(:rsvp).permit(:dates)
  end

  def event_params
    params.require(:event).permit(:name, :description, :date_range, :specificity)
  end

  def fetch_event
    @event = Event.find(params[:id])
  end
end
