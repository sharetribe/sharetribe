# Thanks to Trevor Turk (http://trevorturk.com/2009/06/25/config-vars-and-heroku/)

namespace :heroku do
  task :config do
    puts "Reading config/config.yml and sending PRODUCTION config vars to Heroku..."
    CONFIG = YAML.load_file('config/config.yml')['production'] rescue {}
    command = "heroku config:add"
    CONFIG.each {|key, val|
      command << " #{key}=#{val} " if val
      }
    puts command
    system command
  end
end
