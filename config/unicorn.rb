deploy_to = '/var/www/donalo/'
shared_path = "#{deploy_to}/shared"

working_directory "#{deploy_to}/current"

pid "#{shared_path}/pids/unicorn.pid"
stderr_path "#{shared_path}/log/unicorn.err.log"
stdout_path "#{shared_path}/log/unicorn.std.log"

worker_processes 2

# Leverage Ruby 2.0+'s Copy-On-Write support
preload_app true

before_fork do |server, worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  # the following is *required* for Rails + "preload_app true"
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
