class CreateQuestionerVotes < ActiveRecord::Migration[5.1]
  def change
    create_table :questioner_votes do |t|
      t.integer :voter_id, null: false
      t.integer :questioner_id, null: false
    end
  end
end
