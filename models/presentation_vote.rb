class PresentationVote < ActiveRecord::Base
  belongs_to :voter, class_name: 'Attendee'
  belongs_to :presentation
end
