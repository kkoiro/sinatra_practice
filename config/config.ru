# -*- coding: utf-8 -*-
# Config file for rackup

# 'deployment' or 'development'
# Change the one in app_config as well.
ENV['RACK_ENV'] = 'development'

require_relative '../main'

# Return favicon from Rack
map '/favicon.ico' do
  run Rack::File.new(File.expand_path('../../public/images/favicon.ico', __FILE__))
end

# To support put and delete method 
use Rack::MethodOverride

# Log setting
use Rack::CommonLogger, Logger.new(File.expand_path('../../log/access.log', __FILE__))

run App
