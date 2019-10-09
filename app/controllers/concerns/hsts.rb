module HSTS
  module_function

  def hsts_header(request)
    if APP_CONFIG.always_use_ssl.to_s == "true" && request.ssl?
      community = request.env[:current_marketplace]

      hsts_max_age = if community&.use_domain
                       community.hsts_max_age
                     else
                       APP_CONFIG.hsts_max_age.to_i
                     end

      if hsts_max_age && hsts_max_age > 0
        ['Strict-Transport-Security', "max-age=#{hsts_max_age}"]
      end
    end
  end

  module Concern
    extend ActiveSupport::Concern

    included do
      before_action :set_hsts
    end

    def set_hsts
      header, value = HSTS.hsts_header(request)
      if header
        response.set_header(header, value)
      end
    end
  end
end
