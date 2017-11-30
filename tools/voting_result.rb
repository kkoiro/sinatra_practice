require_relative '../lib/connect_db'
require_relative '../lib/models_loader'


presentation_vote = Hash.new
Presentation.find_each do |presentation|
  presenter_id = presentation.presenter_id
  voted_num = PresentationVote.where(presentation_id: presentation.id).count
  presentation_vote[presenter_id] = voted_num
end

puts "Best Presentator"
puts "id, name, voted_num"
presentation_vote.sort_by{|_, voted_num| -voted_num}.take(5).each do |presenter_id, voted_num|
  presenter_name = Attendee.find(presenter_id).name
  puts "#{presenter_id}, #{presenter_name}, #{voted_num}"
end
puts ""


questioner_vote = Hash.new
Attendee.find_each do |attendee|
  voted_num = QuestionerVote.where(questioner_id: attendee.id).count
  questioner_vote[attendee.id] = voted_num
end

puts "Best questioner"
puts "id, name, voted_num"
questioner_vote.sort_by{|_, voted_num| -voted_num}.take(5).each do |questioner_id, voted_num|
  questioner_name = Attendee.find(questioner_id).name
  puts "#{questioner_id}, #{questioner_name}, #{voted_num}"
end
