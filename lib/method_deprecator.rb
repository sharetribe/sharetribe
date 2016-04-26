class MethodDeprecator < ActiveSupport::Deprecation

  def deprecation_warning(deprecated_method_name, message, caller_backtrace = nil)
    caller_backtrace ||= caller(2)
    message = "#{deprecated_method_name} is deprecated and will be removed in future. | #{message}"
    warn(message, caller_backtrace)
  end
end
