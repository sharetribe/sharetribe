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

# Runs multiple up migrations.
#
# This task is mostly run in Heroku during the deploy. No need to run this locally.
#
# Usage: rake migrate_up[20150226124214, 20150226124215, 20150226124216]
#
task migrate_up: [:environment, "db:load_config"] do |_, args|
  migrate_up(args.extras.map(&:to_i))
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

  fetch_remote_heroku_branch if params[:migrations] != false || params[:css].nil?
  migrations = params[:migrations] == false ? [] : ask_all_migrations_to_run
  abort_if_css_modifications if params[:css].nil?

  deploy_to_server

  unless migrations.empty?
    run_migrations(migrations)
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

def migrate_up(versions)
  raise "Nothing to migrate" if versions.empty?

  versions.each do |version|
    ActiveRecord::Migrator.run(:up, ActiveRecord::Migrator.migrations_paths, version)
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

def run_migrations(versions)
  versions_arg = versions.join(",")

  puts 'Running database migrations ...'
  heroku("run rake migrate_up[#{versions_arg}] --app #{@app}")
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

def ask_all_migrations_to_run
  ask_local_migrations_to_run.concat(ask_heroku_migrations_to_run).sort
end

def ask_local_migrations_to_run
  # List of files added to db/migrate dir
  new_files = `git diff --name-only --diff-filter=A #{@destination}/master..#{@branch} db/migrate`
  migrations = select_down_migrations(parse_added_migration_files(new_files))

  if migrations.empty?
    []
  else
    puts ""
    puts "You are about to deploy #{migrations.length} new migrations:"
    puts ""
    ask_migrations_to_run(migrations)
  end
end

# Returns an array of migration versions to run
def ask_heroku_migrations_to_run
  puts "Checking for pending migrations in heroku ..."
  output = heroku_with_output("run rake db:migrate:status --app #{@app}")
  migrations = select_down_migrations(parse_migration_status(output))

  if migrations.empty?
    []
  else
    puts ""
    puts "There are #{migrations.length} migration in Heroku that have not been run:"
    puts ""
    ask_migrations_to_run(migrations)
  end
end

def select_down_migrations(migrations)
  migrations.select { |migration| migration[:status] == :down }
end

def ask_migrations_to_run(migrations)
  migrations.select { |migration|
      puts "Run migration #{migration[:version]} #{migration[:description]} (y/n)?"
      response = STDIN.gets.strip
      response == 'y' || response == 'Y'
    }
    .map { |migration| migration[:version] }
end

def parse_migration_status(output)
  arr = output.split("\n")
  arr.drop(arr.find_index("-" * 50) + 1).map { |line| parse_status_line(line) }
end

def parse_status_line(line)
  parsed = /^\s*(up|down)\s*(\d{14})\s*(.*)$/.match(line)

  {
    status: parsed[1].to_sym,
    version: parsed[2].to_i,
    description: parsed[3]
  }
end

def parse_added_migration_files(new_files)
  new_files.split("\n").map { |file|
    parsed = /^db\/migrate\/(\d{14})_(.*).rb$/.match(file)

    {
      status: :down, # New local migration is always "down" in Heroku
      version: parsed[1].to_i,
      description: parsed[2].humanize
    }
  }
end
