# Include hook code here

model_path = ''
# Setup additional application directory paths
%w(controllers helpers models views).each do |code_dir|
  file_path = File.join(directory, 'app', code_dir)
  $LOAD_PATH << file_path
  ActiveSupport::Dependencies.load_paths << file_path
  # Tell Rails where to look for out plugin's controller files
  config.controller_paths << file_path if file_path.include?('controllers')
  # By default Rails uses a template_root of RAILS_ROOT/app/views, the plugin
  # views are in the plugin directory so we need to tell Rails where they can
  # be found. I also had to do this to allow the application layout to be used, without
  # this no layout would be used at all. We place the plugin view directory at the end
  # of the array so that the application view will be checked first.
  ActionController::Base.append_view_path file_path if file_path.include?('views')
  model_path = file_path if file_path.include?('models') 
end

# Include smerf classes once Rails have initialised. We need to do this so 
# that YAML will be able know how to unserialize smerf forms we 
# serialize to the DB
require "#{model_path}/smerf_item"
require "#{model_path}/smerf_file"
require "#{model_path}/smerf_group"
require "#{model_path}/smerf_question"
require "#{model_path}/smerf_answer"
require "#{model_path}/smerf_meta_form"

