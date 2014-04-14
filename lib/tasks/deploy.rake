# Adapted from https://gist.github.com/362873

#Deploy and rollback on Heroku in staging and production
#task :deploy_staging => ['deploy:set_staging_app', 'deploy:push', 'deploy:restart', 'deploy:tag']
#task :deploy_production => ['deploy:set_production_app', 'deploy:push', 'deploy:restart', 'deploy:tag']

## generic deploy methods

# Give an environment variable name and convert it to boolean.
# Otherwise return `default`
def env_to_bool(var_name, default)
  value = ENV[var_name] || ""
  if value.downcase == "true"
    true
  elsif value.downcase == "false"
    false
  else
    default
  end
end

# Usage example: Deploy to production without migrations, with css compile
#
# > rake deploy_to[production] migrations=false css=true
#
task :deploy_to, [:destination] do |t, args|
  deploy(
    :destination => args[:destination],
    :migrations => env_to_bool('migrations', true),
    :css => env_to_bool('css', true)
  )
end

task :deploy_without_migrations_to, [:destination] do |t, args|
  deploy(:destination => args[:destination], :migrations => false, :css => env_to_bool('css', true))
end

task :deploy_with_migrations_to, [:destination] do |t, args|
  deploy(:destination => args[:destination], :migrations => true, :css => env_to_bool('css', true))
end

def deploy(params)
  @destination = params[:destination]
  @branch = `git symbolic-ref HEAD`[/refs\/heads\/(.+)$/,1]

  if `git status --porcelain`.present?
    raise "You have unstaged or uncommitted changes! Please only deploy from a clean working directory!"
  end

  puts "Deploying from: #{@branch}"
  puts "Deploying to:   #{@destination}"
  puts "Deploy options:"
  puts "  css:        #{params[:css]}"
  puts "  migrations: #{params[:migrations]}"

  if @destination == "production" || @destination == "preproduction"
    puts "YOU ARE GOING TO DEPLOY #{@branch} BRANCH TO #{@destination}"
    puts "MAKE SURE THE DETAILS ARE CORRECT! Are you sure you want to continue? (y/n)"
    response = STDIN.gets.strip
    exit if response != 'y' && response != 'Y'
  else
    #update_error_page_translations
    Rake::Task["i18n:write_error_pages"].invoke
  end

  set_app(@destination)
  prepare_closed_source_branch
  deploy_to_server
  if params[:migrations]
    run_migrations
    restart
  end
  if params[:css]
    generate_custom_css
  end
end

def set_app(destination)
  @app = "sharetribe-#{destination}"
  puts "Destination Heroku app: #{@app}"
end

def prepare_closed_source_branch
  puts 'Copying closed source contents...'
  puts `mkdir ../tmp-sharetribe` unless File.exists?("../tmp-sharetribe")
  puts `mkdir ../tmp-sharetribe/webfonts` unless File.exists?("../tmp-sharetribe/webfonts")
  puts `rm app/assets/webfonts/* `
  puts `git checkout closed_source`
  # Just in case, check that we really are in the right branch before reset --hard
  if `git symbolic-ref HEAD`.match("refs/heads/closed_source")
    puts `git reset --hard private/closed_source`
    puts `git pull`
    puts `cp -R app/assets/webfonts/* ../tmp-sharetribe/webfonts/`
    puts `cp config/mangopay.pem ../tmp-sharetribe/`
    puts `git rebase #{@branch}`
    puts `git checkout #{@branch}`
    puts `mkdir app/assets/webfonts `
    puts `cp -R ../tmp-sharetribe/webfonts/* app/assets/webfonts/`
    puts `cp ../tmp-sharetribe/mangopay.pem config/`
  else
    puts "ERROR: Checkout for closed_source branch didn't work. Maybe you have uncommitted changes?"
  end
end

def deploy_to_server
  system("git push #{@destination} closed_source:master --force")

end

def run_migrations
  puts 'Running database migrations ...'
  system("heroku run rake db:migrate --app #{@app}")
end

def restart
  puts 'Restarting app servers ...'
  system("heroku restart --app #{@app}")
end

def generate_custom_css
  puts 'Generating custom CSS for tribes who use it ...'
  system("heroku run rake sharetribe:generate_customization_stylesheets --app #{@app}")
end

## STAGING

task :deploy_staging_migrations_from_master => [
  'deploy:set_staging_app',
  'deploy:set_master_as_source_branch',
  'i18n:write_error_pages',
  'deploy:update_closed_source_folders',
  'deploy_with_migrations'
]

task :deploy_staging_migrations_from_develop => [
  'deploy:set_staging_app',
  'deploy:set_develop_as_source_branch',
  'i18n:write_error_pages',
  'deploy:update_closed_source_folders',
  'deploy_with_migrations'
]

task :deploy_staging_without_migrations_from_develop => [
  'deploy:set_staging_app',
  'deploy:set_develop_as_source_branch',
  'i18n:write_error_pages',
  'deploy:update_closed_source_folders',
  'deploy_without_migrations'
]

## PRODUCTION

# this one deploy's the closed_source branch but doesn't update it
task :deploy_production_migrations_from_closed_source => [
  'deploy:set_production_app',
  'deploy_with_migrations'
]

task :deploy_production_migrations_from_master => [
  'deploy:set_production_app',
  'deploy:set_master_as_source_branch',
  'deploy:update_closed_source_folders',
  'deploy_with_migrations'
]

task :deploy_production_without_migrations_from_master => [
  'deploy:set_production_app',
  'deploy:set_master_as_source_branch',
  'deploy:update_closed_source_folders',
  'deploy_without_migrations'
]

# this one deploy's the closed_source branch but doesn't update it
task :deploy_production_without_migrations_from_closed_source => [
  'deploy:set_production_app',
  'deploy_without_migrations'
]

## PRE PRODUCTION

# this one deploy's the closed_source branch but doesn't update it
task :deploy_preproduction_migrations_from_closed_source => [
  'deploy:set_preproduction_app',
  'deploy_with_migrations'
]

task :deploy_preproduction_migrations_from_develop => [
  'deploy:set_preproduction_app',
  'deploy:set_develop_as_source_branch',
  'deploy:update_closed_source_folders',
  'deploy_with_migrations'
]

## TRANSLATION

task :deploy_translation_migrations_from_develop => [
  'deploy:set_translation_app',
  'deploy:set_develop_as_source_branch',
  'deploy:update_closed_source_folders',
  'deploy:push',
  'deploy:migrate',
  'deploy:restart'
]

task :deploy_translation_without_migrations_from_develop => [
  'deploy:set_translation_app',
  'deploy:set_develop_as_source_branch',
  'deploy:update_closed_source_folders',
  'deploy:push'
]

## TESTING

task :deploy_testing_migrations => [
  'deploy:set_testing_app',
  'i18n:write_error_pages',
  'deploy:prepare_custom_branch_for_deploy',
  'deploy_with_migrations'
]

task :deploy_testing_without_migrations => [
  'deploy:set_testing_app',
  'i18n:write_error_pages',
  'deploy:prepare_custom_branch_for_deploy',
  'deploy_without_migrations'
]

task :deploy_test_servers => [
  'deploy_staging_migrations',
  'deploy_translation_migrations'
]

task :deploy_with_migrations => [
  'deploy:push',
  'deploy:migrate',
  'deploy:restart',
  'deploy:generate_custom_css'
]

task :deploy_without_migrations => [
  'deploy:push',
  'deploy:generate_custom_css'
]

namespace :deploy do
  PRODUCTION_APP = 'sharetribe-production'
  PREPRODUCTION_APP = 'sharetribe-preproduction'
  STAGING_APP = 'sharetribe-staging'
  TRANSLATION_APP = "sharetribe-translation"
  TESTING_APP = 'sharetribe-testing'

  task :set_staging_app do
    APP = STAGING_APP
  end

  task :set_testing_app do
    APP = TESTING_APP
  end

  task :set_production_app do
    APP = PRODUCTION_APP
  end

  task :set_preproduction_app do
    APP = PREPRODUCTION_APP
  end

  task :set_translation_app do
    APP = TRANSLATION_APP
  end

  task :set_develop_as_source_branch do
    BRANCH = "develop"
  end

  task :set_master_as_source_branch do
    BRANCH = "master"
  end

  task :update_closed_source_folders do
    puts 'Copying closed source contents...'
    puts `mkdir ../tmp-sharetribe` unless File.exists?("../tmp-sharetribe")
    puts `mkdir ../tmp-sharetribe/webfonts` unless File.exists?("../tmp-sharetribe/webfonts")
    puts `rm app/assets/webfonts/* `
    puts `git checkout closed_source`
    # Just in case, check that we really are in the right branch before reset --hard
    if `git symbolic-ref HEAD`.match("refs/heads/closed_source")
      puts `git reset --hard private/closed_source`
      puts `git pull`
      puts `cp -R app/assets/webfonts/* ../tmp-sharetribe/webfonts/`
      puts `cp config/mangopay.pem ../tmp-sharetribe/`
      puts `git rebase #{BRANCH}`
      puts `git checkout #{BRANCH}`
      puts `mkdir app/assets/webfonts `
      puts `cp -R ../tmp-sharetribe/webfonts/* app/assets/webfonts/`
      puts `cp ../tmp-sharetribe/mangopay.pem config/`
    else
      puts "ERROR: Checkout for closed_source branch didn't work. Maybe you have uncommitted changes?"
    end
  end

  task :push do
    puts 'Deploying site to Heroku ...'
    if APP == PRODUCTION_APP
      puts `git push production closed_source:master --force`
    elsif APP == TRANSLATION_APP
      puts `git push translation closed_source:master --force`
    elsif APP == TESTING_APP
      puts `git push testing closed_source:master --force`
    elsif APP == PREPRODUCTION_APP
      puts `git push preproduction closed_source:master --force`
    else
      puts `git push staging closed_source:master --force`
    end
  end

  task :restart do
    puts 'Restarting app servers ...'
    system("heroku restart --app #{APP}")
  end

  task :generate_custom_css => :environment do
    puts 'Generating custom CSS for tribes who use it ...'
    system("heroku run rake sharetribe:generate_customization_stylesheets --app #{APP}")
  end

  task :tag do
    release_name = "#{APP}_release-#{Time.now.utc.strftime("%Y%m%d%H%M%S")}"
    puts "Tagging release as '#{release_name}'"
    puts `git tag -a #{release_name} -m 'Tagged release'`
    system("git push --tags git@heroku.com:#{APP}.git")
  end

  task :migrate do
    puts 'Running database migrations ...'
    system("heroku run rake db:migrate --app #{APP}")
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
