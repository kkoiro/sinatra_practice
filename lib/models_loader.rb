Dir[File.expand_path('../../models', __FILE__) << '/*.rb'].each do |file|
  require file
end
