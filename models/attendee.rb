class Attendee < ActiveRecord::Base
  belongs_to :organization
  has_many :sessions, foreign_key: "chairperson_id"
  has_many :presentations, foreign_key: "presenter_id"
  has_many :questioner_votes, foreign_key: "questioner_id"
  has_many :presentation_votes, foreign_key: "voter_id"
  has_secure_password
end
