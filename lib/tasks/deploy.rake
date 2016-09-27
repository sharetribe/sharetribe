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

# Usage example: Deploy to production without migrations
#
# > rake deploy_to[production] migrations=false
#
task :deploy_to, [:destination] do |t, args|
  deploy(
    :destination => args[:destination],
    :migrations => env_to_bool('migrations', nil),
    :clear_cache => env_to_bool('clear_cache', nil)
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
  puts "  migrations:  #{params[:migrations]}"
  puts "  clear cache: #{params[:clear_cache]}"

  ask_confirmations!(@destination, @branch, params)

  set_app(@destination)

  fetch_remote_heroku_branch if params[:migrations] != false
  local_migrations = fetch_local_migrations()

  if local_migrations.present?
    update_data_export_script_reminder!(@destination)
  end

  migrations_to_run = params[:migrations] == false ? [] : ask_local_migrations_to_run(local_migrations)

  deploy_to_server

  clear_cache if params[:clear_cache]

  if migrations_to_run.present?
    run_migrations(migrations_to_run)
    restart
  end
end

def update_data_export_script_reminder!(destination)
  if destination == "production"
    puts ""
    puts "Did you remember to update the data export script? (y/n)"
    response = STDIN.gets.strip
    exit if response != 'y' && response != 'Y'
  end
end

def ask_confirmations!(destination, branch, params)
  if destination == "production"
    puts ""
    puts "Did you remember WTI pull? (y/n)"
    response = STDIN.gets.strip
    exit if response != 'y' && response != 'Y'
  end

  if local_css_modifications?
    puts ""
    puts "You are deploying CSS changes. Did you remember to run 'sharetribe:cs_extract' task? (y/n)"
    response = STDIN.gets.strip
    exit if response != 'y' && response != 'Y'
  end

  if params[:migrations] == false
    puts ""
    puts "Skipping migrations, really? (y/n)"
    response = STDIN.gets.strip
    exit if response != 'y' && response != 'Y'
  end

  if destination == "production" || destination == "preproduction"
    puts ""
    puts "YOU ARE GOING TO DEPLOY #{branch} BRANCH TO #{destination}"
    puts "MAKE SURE THE DETAILS ARE CORRECT! Are you sure you want to continue? (y/n)"
    response = STDIN.gets.strip
    exit if response != 'y' && response != 'Y'
  end
end

def set_app(destination)
  @app = "sharetribe-#{destination}"
  puts "Destination Heroku app: #{@app}"
end

def migrate_up(versions)
  raise "Nothing to migrate" if versions.empty?

  versions.each do |version|
    ActiveRecord::Migrator.run(:up, ActiveRecord::Migrator.migrations_paths, version)
  end
end

def local_css_modifications?
  diff = `git diff --name-only #{@branch}..#{@destination}/master -- app/assets/stylesheets`
  !diff.lines.reject{ |l| /^app\/assets\/stylesheets\/landing_page/.match(l) }.empty?
end

# Fixes error: Your Ruby version is 1.9.3, but your Gemfile specified 2.1.1
def heroku(cmd)
  Bundler.with_clean_env { system("heroku #{cmd}") }
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

def fetch_remote_heroku_branch
  puts "Fetching heroku remote branch for checking migration status ..."
  `git fetch #{@destination} master`
end

def fetch_local_migrations
  # List of files added to db/migrate dir
  new_files = `git diff --name-only --diff-filter=A #{@destination}/master..#{@branch} db/migrate`
  select_down_migrations(parse_added_migration_files(new_files))
end

def ask_local_migrations_to_run(migrations)
  if migrations.empty?
    []
  else
    puts ""
    puts "You are about to deploy #{migrations.length} new migrations:"
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

# Remove `output`. It's only for debugging
def parse_status_line(line, output)
  parsed = /^\s*(up|down)\s*(\d{14})\s*(.*)$/.match(line)
  puts "[DEBUG] Regexp didn't match, line: #{line}, result: #{parsed}" if parsed.nil?
  puts "[DEBUG] Output: #{output}" if parsed.nil?

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

def clear_cache
  puts "Clearing Rails cache..."
  heroku("run rails runner Rails.cache.clear --app #{@app}")
  puts "Rails cache cleared"
end
