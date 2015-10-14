class User < ActiveRecord::Base
  obfuscate_id spin: ENV["SPIN"].to_i + 30

  authenticates_with_sorcery! do |config|
    config.authentications_class = Authentication
  end

  attr_accessor :authenticated_with_provider

  has_many :event_users, :dependent => :destroy
  has_many :attended_events, through: :event_users, source: :event
  has_many :created_events, class_name: 'Event', foreign_key: 'creator_id', :dependent => :destroy
  has_many :authentications, :dependent => :destroy
  accepts_nested_attributes_for :authentications

  has_attached_file :avatar, styles: { full: "600x600>", medium: "300x300>", thumb: "160x160>" }
  validates_attachment_content_type :avatar, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  validates :name, presence: true
  validates :password, presence: true, if: :validate_password?
  validates :email, presence: true, uniqueness: true, email: true, unless: :has_linked_provider?

  def has_linked_provider?
    authenticated_with_provider == true || authentications.present?
  end

  def validate_password?
    new_record? || crypted_password_changed?
  end

  def send_emails?
    email.present?
  end

  def receive_emails?
    email.present? && email_notifications?
  end

  def avatar_url(size = :thumb)
    avatar_file_name.try(:start_with?, 'http') ? avatar_file_name : avatar.url(size)
  end

  def password=(new_password)
    @password = new_password if new_password.present?
  end
end
