class Presentation < ActiveRecord::Base
  belongs_to :session
  belongs_to :presenter, class_name: 'Attendee'
  has_many :presentation_votes
end
