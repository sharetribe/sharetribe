
# THIS DEPLOY-FILE CONTAINS LOT OF COMMENTED STUFF BECAUSE THERE ARE SOME PROBLEMS
# RUNNING MONGREL AS DAEMON WITH RAILS 3. CLEAN UP WHEN PROBLEMS SOLVED.

default_run_options[:pty] = true  # Must be set for the password prompt from git to work

set :application, "kassi2"
set :repository,  "git://github.com/sizzlelab/kassi.git"
set :user, "kassi"  # The server's user for deploys
ssh_options[:forward_agent] = true

set :scm, :git
set :branch, "kassi2"

set :deploy_via, :remote_cache

set :deploy_to, "/var/datat/kassi2"


#set :host, "alpha.sizl.org"

if ENV['DEPLOY_ENV']
  set :server_name, ENV['DEPLOY_ENV']
  set :host, "#{ENV['DEPLOY_ENV']}.sizl.org"
else
  set :server_name, "alpha"
  set :host, "alpha.sizl.org"
end

# mongrel_cluster_size = {
#   "alpha" => 2,
#   "beta" => 3,
#   "localhost" => 1
# }

#set :mongrel_cluster_size, mongrel_cluster_size[server_name]
set :mongrel_conf, "#{shared_path}/system/mongrel_cluster.yml"

set :rails_env, :production
set :path, "$PATH:/var/lib/gems/1.8/bin"

role :app, host
role :web, host
role :db, host, :primary => true

set :use_sudo, false

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end

namespace :deploy do
  
  task :before_cold do
    run "killall mongrel_rails" rescue nil
  end
  
  # task :before_start do
  #   mongrel.configure
  # end
  
  task :symlink_listing_images do
    run "rm -rf #{release_path}/public/images/listing_images"
    run "rm -rf #{release_path}/tmp/performance"
    run "ln -fs #{shared_path}/listing_images/ #{release_path}/public/images/listing_images"
    run "ln -fs #{shared_path}/performance/ #{release_path}/tmp/performance"
    run "ln -nfs #{shared_path}/system/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/system/session_secret #{release_path}/config/session_secret"
    run "ln -nfs #{shared_path}/system/config.yml #{release_path}/config/config.yml"
    run "ln -nfs #{shared_path}/system/gmaps_api_key.yml #{release_path}/config/gmaps_api_key.yml"    
  end
  
  # [ :stop, :start, :restart ].each do |t|
  #   task t, :roles => :app do
  #     mongrel.send(t)
  #   end
  # end
  
  desc "Modified restart task to work with mongrel cluster" 
  task :restart, :roles => :app do 
    # run "cd #{deploy_to}/current && mongrel_rails cluster::restart -C 
    # #{shared_path}/system/mongrel_cluster.yml" 
  end 
  desc "Modified start task to work with mongrel cluster" 
  task :start, :roles => :app do 
    # run "cd #{deploy_to}/current && mongrel_rails cluster::start -C 
    #     #{shared_path}/system/mongrel_cluster.yml" 
     run "cd #{deploy_to}/current && rails server -p 3500 -e production"
  end 
  desc "Modified stop task to work with mongrel cluster" 
  task :stop, :roles => :app do 
    # run "cd #{deploy_to}/current && mongrel_rails cluster::stop -C 
    # #{shared_path}/system/mongrel_cluster.yml" 
  end
  
  task :finalize do
    #whenever.write_crontab
    #apache.restart
    run "sudo /etc/init.d/apache2 restart"
  end  
end

before "deploy:migrate", "db:backup"
after 'deploy:update_code', 'deploy:symlink_listing_images'
after %w(deploy deploy:migrations deploy:cold), "deploy:finalize"


