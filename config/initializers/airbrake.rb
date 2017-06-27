if APP_CONFIG.use_airbrake
  Airbrake.configure do |config|
    config.project_id = APP_CONFIG.airbrake_project_id
    config.project_key = APP_CONFIG.airbrake_project_key


    config.root_directory = Rails.root
    config.logger = Rails.logger
    config.environment = Rails.env

    config.ignore_environments = %w(development test)
    config.blacklist_keys = Rails.application.config.filter_parameters
  end

  Airbrake.add_filter do |notice|
    errors_to_ignore = [
      "AbstractController::ActionNotFound",
      "ActiveRecord::RecordNotFound",
      "ActionController::RoutingError",
      "ActionController::UnknownAction",
      "PeopleController::PersonDeleted",
      "PeopleController::PersonBanned",
      "ListingsController::ListingDeleted"
    ]
    if notice[:errors].any? { |error| errors_to_ignore.include?(error[:type]) }
      notice.ignore!
    end
  end
end
