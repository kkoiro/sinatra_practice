# Database initial setup
require 'securerandom'

#######################
#### Organizations ####
#######################

Organization.create(name: 'Org1')
Organization.create(name: 'Org2')


###################
#### Attendees ####
###################

## From China
Attendee.create(name: 'user1', email: 'user1@example.com', password: SecureRandom.hex(4), organization_id: 1, login_secret: SecureRandom.hex(16))
Attendee.create(name: 'user2', email: 'user2@example.com', password: SecureRandom.hex(4), organization_id: 2, login_secret: SecureRandom.hex(16))



####################
#### Time Table ####
####################

## 09:00 ~ 09:25: Reception
## 09:25 ~ 09:40: Opening

# Session1
Session.create(title: 'Plenary Session', chairperson_id: 1, room_id: 1)
Presentation.create(presenter_id: 1, title: 'Modern web development', session_id: 1, start_time: '2017-11-3 09:40:00', finish_time: '2017-11-3 10:00:00')
Presentation.create(presenter_id: 2, title: 'Popular web frameworks', session_id: 1, start_time: '2017-11-3 10:00:00', finish_time: '2017-11-3 10:20:00')


###############
#### Rooms ####
###############

Room.create(name: 'room1')
Room.create(name: 'room2')
