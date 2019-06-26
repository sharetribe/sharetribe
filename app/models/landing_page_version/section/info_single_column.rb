module LandingPageVersion::Section
  class InfoSingleColumn < Info
    class << self
      def permitted_params
        PERMITTED_PARAMS
      end
    end
  end
end

