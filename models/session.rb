class Session < ActiveRecord::Base
  has_many :presentations
  belongs_to :room
  belongs_to :chairperson, class_name: 'Attendee'
end
