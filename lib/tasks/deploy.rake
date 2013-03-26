# Adapted from https://gist.github.com/362873

#Deploy and rollback on Heroku in staging and production
#task :deploy_staging => ['deploy:set_staging_app', 'deploy:push', 'deploy:restart', 'deploy:tag']
#task :deploy_production => ['deploy:set_production_app', 'deploy:push', 'deploy:restart', 'deploy:tag']

task :deploy_staging_migrations => ['deploy:set_staging_app', 'i18n:write_error_pages', 'deploy:update_webfonts_folder', 'deploy:push', 'deploy:migrate', 'deploy:restart', 'deploy:generate_custom_css' ]
task :deploy_production_migrations => ['deploy:set_production_app', 'deploy:push', 'deploy:migrate', 'deploy:restart', 'deploy:generate_custom_css']

task :deploy_staging_without_migrations => ['deploy:set_staging_app', 'i18n:write_error_pages', 'deploy:update_webfonts_folder', 'deploy:push', 'deploy:generate_custom_css']
task :deploy_production_without_migrations => ['deploy:set_production_app', 'deploy:push', 'deploy:generate_custom_css']

task :deploy_custom_migrations => ['deploy:set_staging_app', 'deploy:prepare_custom_branch_for_deploy', 'deploy:push', 'deploy:migrate', 'deploy:restart', 'deploy:generate_custom_css']
task :deploy_custom_quick => ['deploy:set_staging_app', 'deploy:prepare_custom_branch_for_deploy', 'deploy:push']

namespace :deploy do
  PRODUCTION_APP = 'sharetribe-production'
  STAGING_APP = 'sharetribe-staging'

  # task :staging_migrations => [:set_staging_app, :push, :off, :migrate, :restart, :on, :tag]
  # task :staging_rollback => [:set_staging_app, :off, :push_previous, :restart, :on]
  # 
  # task :production_migrations => [:set_production_app, :push, :off, :migrate, :restart, :on, :tag]
  # task :production_rollback => [:set_production_app, :off, :push_previous, :restart, :on]

  task :set_staging_app do
    APP = STAGING_APP
  end

  task :set_production_app do
  	APP = PRODUCTION_APP
  end

  task :update_webfonts_folder do
    puts 'Copying webfonts folder ...'
    puts `rm app/assets/webfonts/* `
    puts `git checkout closed_source`
    puts `cp -R app/assets/webfonts/* ../tmp-sharetribe-webfonts/`
    puts `git rebase develop`
    puts `git checkout develop`
    puts `mkdir app/assets/webfonts `
    puts `cp -R ../tmp-sharetribe-webfonts/* app/assets/webfonts/`
  end
  
  task :prepare_custom_branch_for_deploy do
    puts 'Copying webfonts folder ...'
    puts `rm app/assets/webfonts/* `
    puts `git checkout closed_source`
    puts `cp -R app/assets/webfonts/* ../tmp-sharetribe-webfonts/`
    puts `git rebase custom`
    puts `git checkout custom`
    puts `mkdir app/assets/webfonts `
    puts `cp -R ../tmp-sharetribe-webfonts/* app/assets/webfonts/`
  end
  
  task :push do
    puts 'Deploying site to Heroku ...'
    if APP == PRODUCTION_APP
      puts `git push production closed_source:master --force`
    else
      puts `git push staging closed_source:master --force`
    end
  end
  
  task :restart do
    puts 'Restarting app servers ...'
    puts `heroku restart --app #{APP}`
  end
  
  task :generate_custom_css => :environment do
    puts 'Generating custom CSS for tribes who use it ...'
    puts  `heroku run rake sharetribe:generate_customization_stylesheets --app #{APP}`
  end
  
  task :tag do
    release_name = "#{APP}_release-#{Time.now.utc.strftime("%Y%m%d%H%M%S")}"
    puts "Tagging release as '#{release_name}'"
    puts `git tag -a #{release_name} -m 'Tagged release'`
    puts `git push --tags git@heroku.com:#{APP}.git`
  end
  
  task :migrate do
    puts 'Running database migrations ...'
    puts `heroku run rake db:migrate --app #{APP}`
  end
  
  task :off do
    puts 'Putting the app into maintenance mode ...'
    puts `heroku maintenance:on --app #{APP}`
  end
  
  task :on do
    puts 'Taking the app out of maintenance mode ...'
    puts `heroku maintenance:off --app #{APP}`
  end

  task :push_previous do
    prefix = "#{APP}_release-"
    releases = `git tag`.split("\n").select { |t| t[0..prefix.length-1] == prefix }.sort
    current_release = releases.last
    previous_release = releases[-2] if releases.length >= 2
    if previous_release
      puts "Rolling back to '#{previous_release}' ..."
      
      puts "Checking out '#{previous_release}' in a new branch on local git repo ..."
      puts `git checkout #{previous_release}`
      puts `git checkout -b #{previous_release}`
      
      puts "Removing tagged version '#{previous_release}' (now transformed in branch) ..."
      puts `git tag -d #{previous_release}`
      puts `git push git@heroku.com:#{APP}.git :refs/tags/#{previous_release}`
      
      puts "Pushing '#{previous_release}' to Heroku master ..."
      puts `git push git@heroku.com:#{APP}.git +#{previous_release}:master --force`
      
      puts "Deleting rollbacked release '#{current_release}' ..."
      puts `git tag -d #{current_release}`
      puts `git push git@heroku.com:#{APP}.git :refs/tags/#{current_release}`
      
      puts "Retagging release '#{previous_release}' in case to repeat this process (other rollbacks)..."
      puts `git tag -a #{previous_release} -m 'Tagged release'`
      puts `git push --tags git@heroku.com:#{APP}.git`
      
      puts "Turning local repo checked out on master ..."
      puts `git checkout master`
      puts 'All done!'
    else
      puts "No release tags found - can't roll back!"
      puts releases
    end
  end
end