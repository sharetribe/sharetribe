require 'thinking_sphinx/deploy/capistrano'


default_run_options[:pty] = true  # Must be set for the password prompt from git to work

set :application, "kassi"
set :repository,  "git://github.com/sizzlelab/kassi.git"
set :user, "kassi"  # The server's user for deploys
ssh_options[:forward_agent] = true

set :scm, :git


set :deploy_via, :remote_cache

set :deploy_to, "/var/datat/kassi"

if ENV['DEPLOY_ENV'] == "beta"
  set :server_name, "beta"
  set :host, "beta.sizl.org"
  set :branch, ENV['BRANCH'] || "production"
elsif ENV['DEPLOY_ENV'] == "icsi"
  set :deploy_to, "/opt/kassi"
  set :server_name, "icsi"
  set :host, "sizl.icsi.berkeley.edu"
  set :user, "amvirola"
  set :branch, ENV['BRANCH'] || "production"
elsif ENV['DEPLOY_ENV'] == "delta"
  set :server_name, "alpha"
  set :host, "alpha.sizl.org"
  set :branch, ENV['BRANCH'] || "production"
  set :deploy_to, "/var/datat/deltakassi"
elsif ENV['DEPLOY_ENV'] == "dbtest"
  set :deploy_to, "/var/datat/kassi2dbtest"
  set :server_name, "alpha"
  set :host, "alpha.sizl.org"
  set :branch, ENV['BRANCH'] || "master"
elsif  ENV['DEPLOY_ENV'] == "amazon"
  set :host, "ec2-79-125-82-26.eu-west-1.compute.amazonaws.com"
  set :user, "ubuntu"
  set :server_name, "epsilon"
  set :deploy_to, "/opt/kassi"
  set :branch, ENV['BRANCH'] || "master"
else
  set :server_name, "alpha"
  set :host, "alpha.sizl.org"
  set :branch, ENV['BRANCH'] || "master"
end

set :path, "$PATH:/var/lib/gems/1.8/bin"

role :app, host
role :web, host
role :db, host, :primary => true

set :rails_env, :production
set :use_sudo, false


# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :deploy do
  task :start do ; end
  
  task :stop do ; end
  
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
  
  task :preparations do
    #run "killall mongrel_rails" rescue nil
    #run "killall searchd" rescue nil
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
    
  task :finalize do
    #whenever.write_crontab
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
  whenever.update_crontab
end

after "deploy:update" do
  thinking_sphinx.rebuild
end

after "deploy:setup" do
  thinking_sphinx.shared_sphinx_folder
  thinking_sphinx.configure
  thinking_sphinx.index
  thinking_sphinx.start
end

# Manage Delayed Job similarly as the server.
after "deploy:stop",    "delayed_job:stop"
after "deploy:start",   "delayed_job:start"
after "deploy:restart", "delayed_job:restart"

require 'config/boot'
require 'hoptoad_notifier/capistrano'

