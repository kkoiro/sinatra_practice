require_relative '../config/app_config'
require 'sinatra/base'
require 'active_record'

ActiveRecord::Base.configurations = YAML.load_file(File.expand_path('../../config/database.yml', __FILE__))
ActiveRecord::Base.establish_connection(AppConfig.get_config[:environment])
