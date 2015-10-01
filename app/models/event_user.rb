class EventUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :event
  has_many :times, class_name: 'EventUserTime'

  def update_rsvp(rsvp_hash)
    rsvp_hash.each do |date, options|
      event_user_time = self.times.find_by_time(date.to_datetime) || self.times.new(time: date.to_datetime)
      event_user_time.favorite = !!options["favorite"]
      return false unless event_user_time.save
    end

    self.times.where("time NOT IN (?)", rsvp_hash.keys.map(&:to_datetime)).delete_all

    if save
      event.send_rsvp_mail_from(self) unless event.creator_id == user_id
      true
    else
      false
    end
  end
end
