class Room < ActiveRecord::Base
  has_many :sessions
end
