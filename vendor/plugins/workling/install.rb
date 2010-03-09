require 'fileutils'

plugin_root = File.dirname(__FILE__)

# config files
for file in config = %w{ workling.yml } do
  FileUtils.cp(File.join(plugin_root, 'config', file), File.join(RAILS_ROOT, 'config'))
end

# scripts
for file in script = %w{ workling_starling_client workling_client bj_invoker.rb starling_status.rb } do
  FileUtils.cp File.join(plugin_root, 'script', file), File.join(RAILS_ROOT, 'script')
  FileUtils.chmod 0755, File.join(RAILS_ROOT, 'script', file)
end

puts "\n\ninstalled #{ (script + config).join(", ") } \n\n"
puts IO.read(File.join(File.dirname(__FILE__), 'README.markdown'))