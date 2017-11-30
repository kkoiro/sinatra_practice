# Sinatra app config file


# like static class in C#??
class AppConfig
  @@config = {}

  def self.set_config(key, value)
    @@config.store(key, value)
  end

  def self.get_config
    @@config
  end
end


## Configuration
ENV['RACK_ENV'] = "development"  # Use the same as one in config.ru
{
  # Add items below
  sessions: true,
  protection: false
}.each do |key, val|
  AppConfig.set_config(key, val)
end


## Preprocess
if ENV['RACK_ENV'] == "deployment"
  ENV['RACK_ENV'] = "production"
  AppConfig.set_config(:environment, :production)
else
  AppConfig.set_config(:environment, ENV["RACK_ENV"].to_sym)
end

