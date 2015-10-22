module EventsConcern
  def remember_event(event)
    events = (session[:recent_events] || "").split(',')
    events = [event.to_param.to_s] + events
    session[:recent_events] = events.uniq.slice(0,4).join(',')
  end

  def recent_events
    begin
      Event.find((session[:recent_events] || "").split(','))
    rescue
      session.delete(:recent_events)
      []
    end
  end
end
