if %w[development test].include?(Rails.env)
  QueryTrack::Settings.configure do |config|
    config.duration = 1
    config.logs = true
  end
end
