module MarketplaceService::API

  module Marketplaces

    module_function

    def create(params)

      p = Maybe(params)

      locale = p[:marketplace_language].or_else("en")

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
        domain: Helper.available_domain_based_on(params[:marketplace_name]),
        settings: {"locales" => [locale]},
        name: p[:marketplace_name].or_else("Trial Marketplace"),
        available_currencies: Helper.available_currencies_based_on(p[:marketplace_country].or_else("us")),
        country: params[:marketplace_country] ? params[:marketplace_country].downcase : nil
      }

      community = ::Community.create(community_params)

      TransactionTypeCreator.create(community, transaction_type_name)
      Helper.create_category!("Default", community, locale)

      return community
    end

    module Helper

      module_function

      def available_domain_based_on(initial_domain)

        #TODO should we have some names reserved for internal use?

        if initial_domain.blank?
          initial_domain = "trial_site"
        end

        current_domain = initial_domain.gsub(/[^A-Z0-9_]/i,"-").downcase
        current_domain = current_domain[0..29] #truncate to 30 chars or less

        i = 1
        while ::Community.find_by_domain(current_domain) do
          current_domain = "#{initial_domain}#{i}"
          i += 1
        end

        return current_domain
      end

      def available_currencies_based_on(country_code)
        Maybe(MarketplaceService::AvailableCurrencies::COUNTRY_CURRENCIES[country_code.upcase]).or_else("USD")
      end

      def create_category!(category_name, community, locale)
        category = Category.create!(:community_id => community.id, :url => category_name.downcase)
        CategoryTranslation.create!(:category_id => category.id, :locale => locale, :name => category_name)

      end

    end

  end

end
