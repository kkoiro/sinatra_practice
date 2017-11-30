require_relative '../lib/connect_db'
require_relative '../lib/models_loader'

url_prefix = 'https://cjk.autoidlab.jp/backdoor/'

Attendee.find_each do |attendee|
  url = url_prefix + attendee.login_secret
  puts "#{attendee.name}, #{attendee.email}, #{url}"
end
