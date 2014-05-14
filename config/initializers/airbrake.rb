if APP_CONFIG.use_airbrake
  Airbrake.configure do |config|
    config.api_key = APP_CONFIG.airbrake_api_key
    config.ignore_only  =  ["AbstractController::ActionNotFound",
                            "ActiveRecord::RecordNotFound",
                            "ActionController::RoutingError",
                            #"ActionController::InvalidAuthenticityToken",
                            "ActionController::UnknownAction",
                            #"CGI::Session::CookieStore::TamperedWithCookie"
                            ]
    # The erros above are the defaults (from https://github.com/airbrake/airbrake)
    # commented few out to see how often they happen

    # config.http_open_timeout = 60
    # config.http_read_timeout = 60
  end
end
