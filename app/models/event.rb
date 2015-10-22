class Event < ActiveRecord::Base
  COVERS = 12

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

  scope :ordered, -> { order(:starts_at, :ends_at) }
  scope :available, -> { where.not(state: 'closed').where("ends_at >= ?", Date.today) }
  scope :for, ->(user){ joins("LEFT OUTER JOIN event_users ON events.id = event_users.event_id").where("events.creator_id = ? OR event_users.user_id = ?", user.id, user.id).distinct.select('events.*') }

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

    after_transition :on => :close, :do => :send_close_mails
    after_transition :on => :finalise, :do => :send_finalise_mails
  end

  def date_range=(range)
    dates = range.keys.sort
    self.starts_at = dates.first
    self.ends_at   = dates.last
  end

  def presence_of_dates
    if starts_at.blank? || ends_at.blank?
      errors.add(:date_range, 'Please specify the start and end date.')
    end
  end

  def finalise_with(agreed_time)
    if agreed_time.is_a?(Hash)
      self.agreed_time = agreed_time.keys.first.try(:to_datetime) || best_date
    else
      self.agreed_time = agreed_time || best_date
    end
    finalise!
  end

  def status_name
    case state_name
      when :finalised then 'Finalised'
      when :closed then 'Closed'
      else 'Fuzzy'
    end
  end

  def specificity_name
    case specificity.to_sym
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
      event_user.times.all.reduce(memo) {|m, time|
        tm = time.time.strftime('%F')
        m[tm] ||= { score: 0, favorites: 0, users: [] }
        m[tm][:score] += 1
        m[tm][:favorites] += 1 if time.favorite
        m[tm][:users] << { name: name, favorite: time.favorite }
        m
      }
    } || {}
  end

  def has_rsvps?
    event_users.any?
  end

  def send_rsvp_mail_from(event_user)
    EventMailer.rsvp(event_user).deliver_now! if creator.receive_emails?
  end

  def cover_url(size = :full)
    cover_file_name.try(:start_with?, 'http') ? cover_file_name : cover.url(size)
  end

  def send_close_mails
    event_users.each do |event_user|
      EventMailer.close(event_user).deliver_now! if event_user.user_id != creator_id && event_user.user.receive_emails?
    end
  end

  def send_finalise_mails
    if agreed_time.present?
      event_users.each do |event_user|
        EventMailer.finalise(event_user).deliver_now! if event_user.user_id != creator_id && event_user.user.receive_emails?
      end
    end
  end
end
