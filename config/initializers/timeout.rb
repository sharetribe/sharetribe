# config/initializers/timeout.rb
Rack::Timeout.timeout = 23  # seconds, see also unicorn.rb for timeout config
