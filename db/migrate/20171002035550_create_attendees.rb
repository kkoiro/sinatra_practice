class CreateAttendees < ActiveRecord::Migration[5.1]
  def change
    create_table :attendees do |t|
      t.string :email, null: false
      t.string :name, null: false
      t.string :password_digest, null: false
      t.integer :organization_id, null: false
      t.string :login_secret, null: false
    end

    add_index :attendees, :email, unique: true
    add_index :attendees, :login_secret, unique: true
  end
end
