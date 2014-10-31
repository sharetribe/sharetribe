module MarketplaceService::API

  module Marketplaces

    module_function

    def create(params)
#      puts "In Service #{params.to_yaml}"

      p = Maybe(params)

      transaction_type_name = case p[:marketplace_type].or_else("product")
        when "rental"
          "Rent"
        when "service"
          "Service"
        else # also "product" goes to this default
          "Sell"
        end

      community_params = {
        consent: "SHARETRIBE1.0",
        domain: available_domain_based_on(params[:marketplace_name]),
        settings: {"locales" => [p[:marketplace_language].or_else("en")]},
        name: p[:marketplace_name].or_else("Trial Marketplace"),
        available_currencies: available_currencies_based_on(p[:marketplace_contry].or_else("us"))
      }



      c = Community.create(community_params)

      # TODO
      # trans type
      # category

      return c
    end


    def available_domain_based_on(initial_domain)

      if initial_domain.blank?
        initial_domain = "trial_site"
      end

      current_domain = initial_domain.gsub(/[^A-Z0-9_]/i,"-").downcase
      current_domain = current_domain[0..29] #truncate to 30 chars or less

      i = 1
      while Community.find_by_domain(current_domain) do
        current_domain = "#{initial_domain}#{i}"
        i += 1
      end

      return current_domain
    end

    def available_currencies_based_on(country_code)
      Maybe(MarketplaceService::AvailableCurrencies::COUNTRY_CURRENCIES[country_code.upcase]).or_else("USD")
    end

  end

end
