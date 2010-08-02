default_run_options[:pty] = true  # Must be set for the password prompt from git to work

set :application, "kassi"
set :repository,  "git://github.com/sizzlelab/kassi.git"
set :user, "kassi"  # The server's user for deploys
ssh_options[:forward_agent] = true

set :scm, :git
set :deploy_via, :remote_cache
set :deploy_to, "/var/datat/kassi"

if ENV['DEPLOY_ENV']
  set :server_name, ENV['DEPLOY_ENV']
  set :host, "#{ENV['DEPLOY_ENV']}.sizl.org"
  set :branch, ENV['DEPLOY_ENV']
else
  set :server_name, "alpha"
  set :host, "alpha.sizl.org"
  set :branch, "master"
end

mongrel_cluster_sizes = {
  "alpha" => 5,
  "beta" => 5,
  "localhost" => 1
}

set :mongrel_cluster_size, mongrel_cluster_sizes[server_name]
set :mongrel_conf, "#{shared_path}/system/mongrel_cluster.yml"

set :rails_env, :production

role :app, host
role :web, host
role :db, host, :primary => true

set :use_sudo, false

namespace :deploy do
  
  task :before_cold do
    run "killall mongrel_rails" rescue nil
  end
    
  task :symlink_shared_items do
    run "rm -rf #{release_path}/public/images/listing_images"
    run "rm -rf #{release_path}/tmp/performance"
    run "ln -fs #{shared_path}/listing_images/ #{release_path}/public/images/listing_images"
    run "ln -fs #{shared_path}/performance/ #{release_path}/tmp/performance"
    run "ln -fs #{shared_path}/ferret_index/ #{release_path}/index"
    run "ln -nfs #{shared_path}/system/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/system/session_secret #{release_path}/config/session_secret"
    run "ln -nfs #{shared_path}/system/config.yml #{release_path}/config/config.yml"
    run "ln -nfs #{shared_path}/system/gmaps_api_key.yml #{release_path}/config/gmaps_api_key.yml"    
  end
  
  task :after_symlink do
    run "date '+%d.%m.%Y %k:%M' > #{release_path}/app/views/layouts/_build_date.html.erb"
  end
  
  desc "Run the bundle install on the server"
  task :bundle_install do
    run "cd #{release_path} && bundle install"
  end
  
  task :before_start do
    
    run "cd #{deploy_to}/current"
    run "starling -d -P tmp/pids/starling.pid -q log/"
    begin 
       run "#{deploy_to}/current/script/workling_client stop"
    rescue Capistrano::CommandError => error 
       puts "stoppin workling client failed, but it does not matter: #{error}" 
    end 
    run "RAILS_ENV=production #{deploy_to}/current/script/workling_client start"
    
    run "mongrel_rails cluster::configure -e production -p 8000 -N #{mongrel_cluster_size} -c #{deploy_to}/current -C #{mongrel_conf} -a 127.0.0.1"
  end
  
  desc "Modified restart task to work with mongrel cluster" 
  task :restart, :roles => :app do 
    run "cd #{deploy_to}/current && mongrel_rails cluster::restart -C 
      #{shared_path}/system/mongrel_cluster.yml" 
  end 
  
  desc "Modified start task to work with mongrel cluster" 
  task :start, :roles => :app do 
    run "cd #{deploy_to}/current && mongrel_rails cluster::start -C 
      #{shared_path}/system/mongrel_cluster.yml" 
  end 
  
  desc "Modified stop task to work with mongrel cluster" 
  task :stop, :roles => :app do 
    run "cd #{deploy_to}/current && mongrel_rails cluster::stop -C 
      #{shared_path}/system/mongrel_cluster.yml" 
  end
  
  task :finalize do
    #whenever.write_crontab
    run "sudo /etc/init.d/apache2 restart"
  end  
end

#before "deploy:migrate", "db:backup"
after 'deploy:update_code', 'deploy:symlink_shared_items'
after %w(deploy:migrations deploy:cold deploy:start deploy:restart), "deploy:finalize"


