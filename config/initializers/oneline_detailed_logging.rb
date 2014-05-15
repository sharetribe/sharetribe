# Source: https://gist.github.com/troy/3310392

# Outputs this at warn log level:
# 1.2.3.4 GET /path 200 OK BlahController#action HTML 938.2 (DB 11.8, View 719.7) {params} {optional params from flash[:log]}
#
# Save as config/initializers/oneline_detailed_logging.rb. Consider
# decreasing the log level from "info" to "warn" (in production.rb) so
# the one-line log message replaces the standard request logs.

# override process_action to add 2 things to the payload:
# - remote IP
# - an optional stash which is available to subscribers. Basically, flash[:log].inspect will be logged.
# 3.0: https://github.com/rails/rails/blob/3-0-stable/actionpack/lib/action_controller/metal/instrumentation.rb
# 3.1: https://github.com/rails/rails/blob/master/actionpack/lib/action_controller/metal/instrumentation.rb
ActionController::Instrumentation.send(:define_method, "process_action") do |arg|
  raw_payload = {
    :controller => self.class.name,
    :action     => self.action_name,
    :params     => request.filtered_parameters,
    :formats    => request.formats.map(&:to_sym),
    :method     => request.method,
    :path       => (request.fullpath rescue "unknown"),

    :ip         => request.remote_ip,
    :stash      => request.session['flash'] && request.session['flash'][:log]
  }

  ActiveSupport::Notifications.instrument("start_processing.action_controller", raw_payload.dup)

  ActiveSupport::Notifications.instrument("process_action.action_controller", raw_payload) do |payload|
    result = super(arg)
    payload[:status] = response.status
    append_info_to_payload(payload)
    result
  end
end

ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, start, finish, id, payload|
  # borrows from
  # https://github.com/rails/rails/blob/3-0-stable/actionpack/lib/action_controller/log_subscriber.rb
  params  = payload[:params].except('controller', 'action', 'format', '_method', 'only_path')

  format  = payload[:formats].first.to_s.upcase
  duration = (finish-start)*1000

  status = payload[:status]
  if status.nil? && payload[:exception].present?
    # 3.1: http://rubydoc.info/docs/rails/3.1.1/ActionController/LogSubscriber#process_action-instance_method
    # line below got deprecated, replaced with the one from: https://gist.github.com/kyamaguchi/4231083
    # status = Rack::Utils.status_code(ActionDispatch::ShowExceptions.rescue_responses[payload[:exception].first]) rescue nil
    exception_class_name = payload[:exception].first
    status = ActionDispatch::ExceptionWrapper.status_code_for_exception(exception_class_name) rescue nil
  end

  m = "%s %s %s %s %s %s\#%s %s %.1f (DB %.1f, View %.1f) %s %s" % [
    payload[:ip], payload[:method], payload[:path],
    status, Rack::Utils::HTTP_STATUS_CODES[status],
    payload[:controller], payload[:action], format,
    duration || 0, payload[:db_runtime] || 0, payload[:view_runtime] || 0,
    params.inspect, payload[:stash].try(:inspect) || {}.inspect ]

  Rails.logger.warn(m)

  # This is added to get full stack trace to log, which was previously hidden for errors during AJAX calls in tests
  if Rails.env.test? && status.to_i > 399 #only print out errors in tests
    Rails.logger.error($!)
    if $!.present?
      $!.backtrace.each {|line| Rails.logger.error(line) }
    end
  end
end
