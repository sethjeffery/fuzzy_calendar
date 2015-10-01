class EventMailer < ApplicationMailer
  add_template_helper EventsHelper

  def rsvp(event_user)
    @creator = event_user.event.creator
    @sender  = event_user.user
    @event   = event_user.event
    @times   = event_user.times

    mail to: @creator.email, subject: "RSVP received for #{@event.name}"
  end

  def finalise(event)

  end
end
