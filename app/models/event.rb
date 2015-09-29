class Event < ActiveRecord::Base
  obfuscate_id spin: ENV["SPIN"].to_i + 29

  has_many :event_users
  has_many :attendees, through: :event_users, source: :user
  has_many :comments, as: :commentable
  belongs_to :creator, class_name: 'User'

  has_attached_file :cover, styles: { full: "1200x800>", thumb: "300x200>" }
  validates_attachment_content_type :cover, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  validates_inclusion_of :specificity, in: %w(month week day time)
  validates_presence_of :name, message: "Please give your event a name."
  validate :presence_of_dates

  state_machine :state, initial: :open do
    event :close do
      transition [:open, :confirmed] => :closed
    end

    event :finalise do
      transition [:open] => :finalised
    end

    event :reopen do
      transition [:closed] => :open
    end
  end

  def date_range=(range)
    dates = range.split(',').map{|date| Date.parse(date)}
    self.starts_at = dates[0]
    self.ends_at   = dates[1]
  end

  def presence_of_dates
    if starts_at.blank?
      errors.add(:starts_at, 'Please specify the start and end date.')
    elsif ends_at.blank?
      errors.add(:ends_at, 'Please specify the start and end date.')
    end
  end

  def status_name
    case state
      when :finalised then 'Finalised'
      when :closed then 'Closed'
      else 'Fuzzy'
    end
  end

  def specificity_name
    case specificity
      when :day then 'date'
      else specificity.to_s
    end
  end

  def best_date
    Date.parse(scored_dates.sort_by{|k, v| [ -v[:score], -v[:favorites] ] }.first[0]) if scored_dates.present?
  end

  def scored_dates
    @scored_dates ||= event_users.reduce({}){|memo, event_user|
      name = event_user.user.name
      event_user.times.reduce(memo) {|m, time|
        m[time.time.strftime('%F')] ||= { score: 0, favorites: 0, users: [] }
        m[time.time.strftime('%F')][:score] += 1
        m[time.time.strftime('%F')][:favorites] += 1 if time.favorite
        m[time.time.strftime('%F')][:users] << { name: name, favorite: time.favorite }
        m
      }
    } || {}
  end
end
