module LayoutHelper

  # Get a local variable. This is useful in layouts, since locals are not available
  # in them by default.
  #
  # Behaves like local variables, i.e. throws if variable is not available
  #
  # See more http://stackoverflow.com/questions/7382496/how-to-pass-a-variable-to-a-layout
  #
  def locals(local_assigns, key)
    raise "Local variable '#{key}' is not available." unless local_assigns.has_key?(key)

    local_assigns[key]
  end
end
