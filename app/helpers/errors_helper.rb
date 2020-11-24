module ErrorsHelper

  # If an attempt to create a new person results to errors,
  # this method can be used to set the errors from the
  # exception to the errors of the person.
  def add_errors_from(exception)
    if exception
      JSON.parse(exception.response.body)["messages"].each do |error|
        error_array = error.split(" ", 2)
        errors.add(error_array[0].downcase, error_array[1])
      end
    end
  end

end
