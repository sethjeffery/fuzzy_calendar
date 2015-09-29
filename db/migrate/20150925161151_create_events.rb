class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.integer :creator_id,      null: false
      t.datetime :starts_at,      null: false
      t.datetime :ends_at,        null: false
      t.datetime :agreed_time
      t.string :name,             null: false
      t.string :description
      t.string :specificity,      null: false, default: 'day'
      t.string :state,            null: false, default: 'open'

      t.timestamps null: false
    end

    add_index :events, :creator_id
  end
end
