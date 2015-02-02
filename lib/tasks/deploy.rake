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
    :migrations => env_to_bool('migrations', nil),
    :css => env_to_bool('css', nil)
  )
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
  puts "  migrations: #{params[:migrations]} "

  if @destination == "production"
    puts ""
    puts "Did you remember WTI pull? (y/n)"
    response = STDIN.gets.strip
    exit if response != 'y' && response != 'Y'
  end

  if params[:migrations] == false
    puts ""
    puts "Skipping migrations, really? (y/n)"
    response = STDIN.gets.strip
    exit if response != 'y' && response != 'Y'
  end

  if params[:css] == false
    puts ""
    puts "Skipping css compiling, really? (y/n)"
    response = STDIN.gets.strip
    exit if response != 'y' && response != 'Y'
  end

  if @destination == "production" || @destination == "preproduction"
    puts "YOU ARE GOING TO DEPLOY #{@branch} BRANCH TO #{@destination}"
    puts "MAKE SURE THE DETAILS ARE CORRECT! Are you sure you want to continue? (y/n)"
    response = STDIN.gets.strip
    exit if response != 'y' && response != 'Y'
  end

  set_app(@destination)

  fetch_remote_heroku_branch if params[:migrations].nil? || params[:css].nil?
  abort_if_pending_migrations if params[:migrations].nil?
  abort_if_css_modifications if params[:css].nil?

  deploy_to_server

  if params[:migrations]
    run_migrations
    restart
  end
  if params[:css]
    generate_custom_css
  end

  airbrake_trigger_deploy(@destination)
end

def set_app(destination)
  @app = "sharetribe-#{destination}"
  puts "Destination Heroku app: #{@app}"
end

def airbrake_trigger_deploy(destination)
  puts ""
  puts "Triggering airbrake deploy..."
  ENV['use_airbrake'] = "true"
  ENV['TO'] = destination
  Rake::Task['airbrake:deploy'].invoke
  puts "Done."
end

def abort_if_pending_migrations
  pending_heroku_migrations = pending_migrations_in_heroku?
  pending_local_migrations = pending_local_migrations?

  if pending_heroku_migrations || pending_local_migrations
    puts ""
    puts "Heroku has deployed migrations that are not yet run." if pending_heroku_migrations
    puts "You are about to deploy migrations from a local branch." if pending_local_migrations
    puts ""
    puts "Run migrations with rake deploy_to[#{@destination}] migrations=true"
    puts "If you know what you are doing, skip with migrations=false"
    puts "Aborting deploy process."
    exit
  end
end

def abort_if_css_modifications
  if local_css_modifications?
    puts ""
    puts "You have local changes to css files."
    puts "Run css compile with rake deploy_to[#{@destination}] css=true"
    puts "If you know what you are doing, skip with css=false"
    puts "Aborting deploy process."
    exit
  end
end

def local_css_modifications?
  diff = `git diff --shortstat #{@branch}..#{@destination}/master app/assets/stylesheets`
  !diff.empty?
end

# Fixes error: Your Ruby version is 1.9.3, but your Gemfile specified 2.1.1
def heroku(cmd)
  Bundler.with_clean_env { system("heroku #{cmd}") }
end

def heroku_with_output(cmd)
  Bundler.with_clean_env { `heroku #{cmd}` }
end

def deploy_to_server
  system("git push #{@destination} #{@branch}:master --force")

end

def run_migrations
  puts 'Running database migrations ...'
  heroku("run rake db:migrate --app #{@app}")
end

def restart
  puts 'Restarting app servers ...'
  heroku("restart --app #{@app}")
end

def generate_custom_css
  puts 'Generating custom CSS for tribes who use it ...'
  heroku("run rake sharetribe:generate_customization_stylesheets --app #{@app}")
end

def fetch_remote_heroku_branch
  puts "Fetching heroku remote branch for checking migration and css statuses ..."
  `git fetch #{@destination} master`
end

def pending_migrations_in_heroku?
  puts "Checking for pending migrations in heroku ..."
  output = heroku_with_output("run rake db:migrate:status --app #{@app}")
  arr = output.split("\n")
  statuses = arr.drop(arr.find_index("-" * 50) + 1)
    .map(&:strip)
    .map { |str| str.split(" ").first }
  statuses.include?("down")
end

def pending_local_migrations?
  diff = `git diff --shortstat #{@branch}..#{@destination}/master db/migrate`
  !diff.empty?
end
