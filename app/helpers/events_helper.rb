module EventsHelper
  def months_between(start_date, end_date)
    (0..(year_and_month(end_date) - year_and_month(start_date))).map do |i|
      start_date.beginning_of_month + i.months
    end
  end

  def year_and_month(date)
    date.year * 12 + date.month
  end

  def same_calendar?(start_date, end_date)
    year_and_month(start_date) == year_and_month(end_date)
  end

  def my_rsvp(event)
    if logged_in?
      event.event_users.find_by_user_id(current_user.id)
    end
  end

  def my_dates_json(event, with_details=true)
    if logged_in?
      rsvp = my_rsvp(event)
      return unless rsvp
      rsvp.times.map{|time|
        [time.time.strftime('%F'), with_details ? time.as_json : {}]
      }.to_h
    end
  end

  def mine?(event)
    event.creator == current_user
  end

  def specificity_long_format(specificity, date)
    case specificity.to_sym
      when :week
        "w/c #{date.strftime('%-d %B %Y')}"
      when :month
        date.strftime('%B %Y')
      else
        date.strftime('%A, %-d %B %Y')
    end
  end

  def my_events
    Event.for(current_user).available.ordered
  end

  def has_rsvp?(event)
    event.event_users.where(user_id: current_user.id).exists?
  end
end
