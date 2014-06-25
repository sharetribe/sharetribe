# Thanks to Trevor Turk (http://trevorturk.com/2009/06/25/config-vars-and-heroku/)

# Fixes error: Your Ruby version is 1.9.3, but your Gemfile specified 2.1.1
def heroku(cmd)
  Bundler.with_clean_env { system("heroku #{cmd}") }
end


namespace :heroku do
  task :config do
    puts "Reading config/config.yml and sending PRODUCTION config vars to Heroku..."
    CONFIG = YAML.load_file('config/config.yml')['production'] rescue {}
    command = "config:add"
    CONFIG.each {|key, val|
      command << " #{key}=#{val} " if val
      }
    puts command
    heroku(command)
  end
end
