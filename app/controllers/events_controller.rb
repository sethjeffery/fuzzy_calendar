class EventsController < ApplicationController
  include EventsConcern

  before_filter :authenticate!, except: [:index, :show]
  before_filter :fetch_event, except: [:index, :new, :create]
  before_filter :authenticate_event!, only: [:edit, :update, :close, :finalise]

  def show
    remember_event(@event)
  end

  def new
    cover_path = "covers/cover-#{sprintf('%03d', (srand % Event::COVERS + 1))}.jpg"
    @event = Event.new(cover_file_name: view_context.image_url(cover_path))
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
    @event_user = @event.event_users.find_or_create_by(user_id: current_user.id)

    if @event_user.update_rsvp(rsvp_params[:dates])
      redirect_to @event
    else
      redirect_to @event, alert: "Sorry, there was an error saving your RSVP."
    end
  end

  def close
    @event.close!
    redirect_to @event
  end

  def finalise
    @event.finalise_with finalise_params["agreed_time"]
    redirect_to @event
  end

  private

  def rsvp_params
    params.require(:rsvp).permit(:dates).tap{|x| parse_json_params(x, :dates)}
  end

  def event_params
    params.require(:event).permit(:name, :description, :date_range, :specificity, :cover_file_name).tap{|x| parse_json_params(x, :date_range)}
  end

  def finalise_params
    params.require(:event).permit(:agreed_time).tap{|x| parse_json_params(x, :agreed_time)}
  end

  def fetch_event
    @event = Event.find(params[:id])
  end

  def authenticate_event!
    not_found unless @event.creator == current_user
  end
end
