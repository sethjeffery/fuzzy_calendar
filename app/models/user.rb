class User < ActiveRecord::Base
  obfuscate_id spin: ENV["SPIN"].to_i + 30

  authenticates_with_sorcery! do |config|
    config.authentications_class = Authentication
  end

  has_many :event_users, :dependent => :destroy
  has_many :attended_events, through: :event_users, source: :event
  has_many :created_events, class_name: 'Event', foreign_key: 'creator_id', :dependent => :destroy
  has_many :authentications, :dependent => :destroy
  accepts_nested_attributes_for :authentications

  has_attached_file :avatar, styles: { full: "600x600>", medium: "300x300>", thumb: "80x80>" }
  validates_attachment_content_type :avatar, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  validates :name, presence: true
  validates :password, presence: true, allow_nil: true
  validates :email, presence: true, uniqueness: true, allow_nil: true, unless: :has_linked_facebook?

  def has_linked_facebook?
    authentications.where(provider: 'facebook').present?
  end

  def send_emails?
    email.present?
  end
end
