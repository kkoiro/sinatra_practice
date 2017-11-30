class Organization < ActiveRecord::Base
  has_many :attendees
end
