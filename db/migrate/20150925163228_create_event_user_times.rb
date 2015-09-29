class CreateEventUserTimes < ActiveRecord::Migration
  def change
    create_table :event_user_times do |t|
      t.integer :event_user_id,     null: false
      t.datetime :time,             null: false
      t.boolean :favorite,          null: false, default: false

      t.timestamps null: false
    end

    add_index :event_user_times, :event_user_id
  end
end
