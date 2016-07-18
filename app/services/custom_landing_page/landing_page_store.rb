# rubocop:disable ConstantName

module CustomLandingPage

  # Use appropriate LandingPageStore implementation
  #
  # This method of dynamic module access point is Rails autoloading friendly.
  # http://guides.rubyonrails.org/autoloading_and_reloading_constants.html#autoloading-and-initializers

  LandingPageStore =
    if APP_CONFIG.clp_static_enabled.to_s == "true"
      LandingPageStoreStatic.new(APP_CONFIG.clp_static_released_version)
    else
      LandingPageStoreDB
    end

end
