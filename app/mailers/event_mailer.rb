class EventMailer < ApplicationMailer
  add_template_helper EventsHelper

  def rsvp(event_user)
    @creator = event_user.event.creator
    @sender  = event_user.user
    @event   = event_user.event
    @times   = event_user.times

    mail to: @creator.email, subject: "RSVP received: #{@event.name}"
  end

  def finalise(event_user)
    @creator = event_user.event.creator
    @recipient = event_user.user
    @event   = event_user.event

    mail to: @recipient.email, subject: "Event finalised: #{@event.name}"
  end

  def close(event_user)
    @creator = event_user.event.creator
    @recipient = event_user.user
    @event   = event_user.event

    mail to: @recipient.email, subject: "Event closed: #{@event.name}"
  end
end
