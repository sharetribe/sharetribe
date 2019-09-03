# keep this matcher last
# catches all non matched routes, shows 404 and logs more reasonably than the alternative RoutingError + stacktrace
Rails.application.routes.append do
  match "*path" => "errors#not_found", via: :all
end
