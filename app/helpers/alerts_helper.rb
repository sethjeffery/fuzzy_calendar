module AlertsHelper
  def notifications
    @notifications ||= get_notifications
  end

  def notifications?
    notifications.present?
  end

  def alerts?(model=nil)
    flash.present? || model.try(:errors).try(:present?)
  end

  private

  def get_notifications
    return [] unless current_user
    alerts = []

    alerts << no_email_alert
    alerts << no_picture_alert
    alerts << event_without_rsvp_alert

    alerts.compact
  end

  def no_email_alert
    Alert.new("Please provide an email address for event notifications.", "envelope", me_path) if current_user.email.blank?
  end

  def no_picture_alert
    Alert.new("You have no profile picture. Upload one now!", "picture", me_path) if current_user.avatar_file_name.blank?
  end

  def event_without_rsvp_alert
    rsvp_event_ids = current_user.attended_events.select(:event_id).distinct.map(&:event_id)
    event_without_rsvp = current_user.created_events.where("id NOT IN (?)", rsvp_event_ids).first
    Alert.new("You should RSVP to your own event.", "pen", event_path(event_without_rsvp)) if event_without_rsvp
  end
end
