class EventUserTime < ActiveRecord::Base
  belongs_to :event_user

  def as_json
    { favorite: favorite }
  end
end
