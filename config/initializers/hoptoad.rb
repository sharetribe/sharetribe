if APP_CONFIG.use_hoptoad
  HoptoadNotifier.configure do |config|
    config.api_key = 'ea9c77b4d7eb6ae2b42e793fd64b3b28'
    # config.http_open_timeout = 60
    # config.http_read_timeout = 60
  end
end
