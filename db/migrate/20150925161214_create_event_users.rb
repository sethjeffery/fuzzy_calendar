class CreateEventUsers < ActiveRecord::Migration
  def change
    create_table :event_users do |t|
      t.integer :event_id,      null: false
      t.integer :user_id,       null: false

      t.timestamps null: false
    end

    add_index :event_users, [:event_id, :user_id], unique: true
    add_index :event_users, :user_id
  end
end
