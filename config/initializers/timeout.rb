# config/initializers/timeout.rb
if Rails.env.production?
  Rack::Timeout.timeout = 23 # seconds, see also unicorn.rb for timeout config
else
  Rails.configuration.middleware.delete Rack::Timeout
end
