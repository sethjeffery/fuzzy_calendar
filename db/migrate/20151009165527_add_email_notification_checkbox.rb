class AddEmailNotificationCheckbox < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.boolean :email_notifications, default: true, null: false
    end
  end
end
