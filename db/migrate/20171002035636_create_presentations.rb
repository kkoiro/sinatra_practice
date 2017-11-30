class CreatePresentations < ActiveRecord::Migration[5.1]
  def change
    create_table :presentations do |t|
      t.integer :presenter_id, null: false
      t.string :title, null: false
      t.string :slide_title, default: 'Not Uploaded'
      t.boolean :slide, default: false, null: false
      t.integer :session_id, null: false
      t.datetime :start_time, null: false
      t.datetime :finish_time, null: false
    end
  end
end
