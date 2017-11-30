class QuestionerVote < ActiveRecord::Base
  belongs_to :voter, class_name: 'Attendee'
  belongs_to :questioner, class_name: 'Attendee'
end
