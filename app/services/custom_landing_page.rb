module CustomLandingPage
  class LandingPageError < StandardError; end
  class LandingPageConfigurationError < LandingPageError; end
  class LandingPageNotFound < LandingPageError; end
  class LandingPageContentNotFound < LandingPageError; end
end
