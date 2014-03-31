# Helps passing JSON data to JavaScript
class JSAdapter
  include ApplicationController::DefaultURLOptions

  # Due to the way Rails includes the url helpers, this has to be AFTER DefaultURLOptions.
  include Rails.application.routes.url_helpers

  def to_hash
    instance_hash = instance_variables.inject({}) do |hash, var|
      hash[var.to_s.delete("@")] = instance_variable_get(var)
      hash
    end
    Util::HashUtils.camelize_keys(instance_hash)
  end
end