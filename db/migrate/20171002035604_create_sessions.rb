class CreateSessions < ActiveRecord::Migration[5.1]
  def change
    create_table :sessions do |t|
      t.string :title, null: false
      t.integer :chairperson_id, null: false
      t.integer :room_id, null: false
    end
  end
end
