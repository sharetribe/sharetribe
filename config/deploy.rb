require 'thinking_sphinx/deploy/capistrano'


default_run_options[:pty] = true  # Must be set for the password prompt from git to work

set :application, "kassi2"
set :repository,  "git://github.com/sizzlelab/kassi.git"
set :user, "kassi"  # The server's user for deploys
ssh_options[:forward_agent] = true

set :scm, :git
set :branch, "kassi2"

set :deploy_via, :remote_cache

set :deploy_to, "/var/datat/kassi2"
set :port, 3500

if ENV['DEPLOY_ENV']
  set :server_name, ENV['DEPLOY_ENV']
  set :host, "#{ENV['DEPLOY_ENV']}.sizl.org"
else
  set :server_name, "alpha"
  set :host, "alpha.sizl.org"
end

# temporary settings for DB-testing
if ENV['DEPLOY_ENV'] == "dbtest"
  set :deploy_to, "/var/datat/kassi2dbtest"
  set :server_name, "alpha"
  set :host, "alpha.sizl.org"
  set :port, 3550
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
  
  task :preparations do
    run "killall mongrel_rails" rescue nil
    run "killall searchd" rescue nil
  end
  
  task :symlinks_to_shared_path do
    run "rm -rf #{release_path}/public/images/listing_images"
    run "rm -rf #{release_path}/tmp/performance"
    run "ln -fs #{shared_path}/listing_images/ #{release_path}/public/images/listing_images"
    run "ln -fs #{shared_path}/performance/ #{release_path}/tmp/performance"
    run "ln -nfs #{shared_path}/system/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/system/session_secret #{release_path}/config/session_secret"
    run "ln -nfs #{shared_path}/system/config.yml #{release_path}/config/config.yml"
    run "ln -nfs #{shared_path}/system/gmaps_api_key.yml #{release_path}/config/gmaps_api_key.yml"
    run "ln -nfs #{shared_path}/db/sphinx #{release_path}/db/sphinx"
    run "ln -nfs #{shared_path}/vendor_bundle #{release_path}/vendor/bundle"
    if ENV['DEPLOY_ENV'] == "dbtest"
      run "ln -nfs #{shared_path}/system/sphinx.yml #{release_path}/config/sphinx.yml"
    end 
  end

  desc "Run the bundle install on the server"
  task :bundle do
    run "cd #{release_path} && RAILS_ENV=#{rails_env} bundle install --deployment --without test"
  end
    
  desc "Modified restart task to work with mongrel cluster" 
  task :restart, :roles => :app do 
    # run "cd #{deploy_to}/current && mongrel_rails cluster::restart -C 
    # #{shared_path}/system/mongrel_cluster.yml" 
    deploy.stop
    deploy.start
  end 
  desc "Modified start task to work with mongrel cluster" 
  task :start, :roles => :app do 
    # run "cd #{deploy_to}/current && mongrel_rails cluster::start -C 
    #     #{shared_path}/system/mongrel_cluster.yml" 
    
     run "cd #{deploy_to}/current && rails server -p #{port} -e production -d"
  end 
  desc "Modified stop task to work with mongrel cluster" 
  task :stop, :roles => :app do 
    # run "cd #{deploy_to}/current && mongrel_rails cluster::stop -C 
    # #{shared_path}/system/mongrel_cluster.yml" 
    run "cd #{current_path} && mongrel_rails stop -p tmp/pids/server.pid" rescue nil
  end
  
  task :finalize do
    #whenever.write_crontab
    #apache.restart
    run "sudo /etc/init.d/apache2 restart"
  end  
end

before "cold" do
  preparations
end

after %w(deploy:migrations deploy:cold deploy:start ) do
  deploy.finalize
end

after "deploy:update_code" do
  deploy.symlinks_to_shared_path
  deploy.bundle
  thinking_sphinx.rebuild
  whenever.update_crontab
end

after "deploy:setup" do
  thinking_sphinx.shared_sphinx_folder
  thinking_sphinx.configure
  thinking_sphinx.index
  thinking_sphinx.start
end


