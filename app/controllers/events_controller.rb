class EventsController < ApplicationController
  before_filter :fetch_event, except: [:index, :new]
  before_filter :authenticate_event!, only: [:edit, :update, :close, :finalise]

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
    new_event_user = false
    @event_user = @event.event_users.find_by_user_id(current_user.id)

    unless @event_user
      @event_user = @event.event_users.create(user_id: current_user.id)
      new_event_user = true
    end

    dates = JSON.parse(rsvp_params[:dates])
    dates.each do |date, options|
      event_user_time = @event_user.times.find_by_time(date.to_datetime) || @event_user.times.new(time: date.to_datetime)
      event_user_time.favorite = !!options["favorite"]
      event_user_time.save!
    end

    @event_user.times.where("time NOT IN (?)", dates.keys.map(&:to_datetime)).delete_all
    @event_user.save!

    if new_event_user && @event.creator != current_user
      RsvpMailer.rsvp(@event_user).deliver!
    end

    redirect_to @event
  end

  def close

  end

  def finalise

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

  def authenticate_event!
    not_found unless @event.creator == current_user
  end
end
