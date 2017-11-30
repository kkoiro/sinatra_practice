class CreatePresentationVotes < ActiveRecord::Migration[5.1]
  def change
    create_table :presentation_votes do |t|
      t.integer :voter_id, null: false
      t.integer :presentation_id, null: false
    end
  end
end
