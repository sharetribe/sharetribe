require 'fileutils'

#Copy the Javascript files
FileUtils.copy(Dir[File.dirname(__FILE__) + '/javascript/*.js'], File.dirname(__FILE__) + '/../../../public/javascripts/')

#copy the gmaps_api_key file
gmaps_config = File.dirname(__FILE__) + '/../../../config/gmaps_api_key.yml'
unless File.exist?(gmaps_config)
  FileUtils.copy(File.dirname(__FILE__) + '/gmaps_api_key.yml.sample',gmaps_config)
end
