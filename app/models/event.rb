class Event < ActiveRecord::Base
  obfuscate_id spin: 2957029

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

    event :confirm do
      transition [:open] => :confirmed
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
      when :confirmed then 'Confirmed'
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
end
