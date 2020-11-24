module ParamsToAirbrake
  def params_to_airbrake=(params)
    @params_to_airbrake = params
  end

  def to_airbrake
    { params: @params_to_airbrake }
  end
end

