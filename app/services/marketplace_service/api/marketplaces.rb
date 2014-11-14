module MarketplaceService::API

  module Marketplaces
    CommunityModel = ::Community

    RESERVED_DOMAINS = %w(www home sharetribe login blog catch webhooks dashboard dashboardtranslate translate community wiki mail secure host feed feeds app)

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

      marketplace_name = p[:marketplace_name].or_else("Trial Marketplace")

      community_params = {
        consent: "SHARETRIBE1.0",
        domain: Helper.available_domain_based_on(params[:marketplace_name]),
        settings: {"locales" => [locale]},
        name: marketplace_name,
        available_currencies: Helper.available_currencies_based_on(p[:marketplace_country].or_else("us")),
        country: params[:marketplace_country] ? params[:marketplace_country].upcase : nil,
        paypal_enabled: true
      }
      community = CommunityModel.create(community_params)

      customization_params = {
        name: marketplace_name,
        locale: locale
      }
      community.community_customizations.create(customization_params)

      TransactionTypeCreator.create(community, transaction_type_name)
      Helper.create_category!("Default", community, locale)

      return from_model(community)
    end

    # Create a Marketplace hash from Community model
    def from_model(community)
      hash = HashUtils.compact(
        EntityUtils.model_to_hash(community).merge({
            url: community.full_domain({with_protocol: true}),
            locales: community.locales
          }))
      # remove locale from settings as it's in the root level of the hash
      hash[:settings].delete("locales")
      return MarketplaceService::API::DataTypes::create_marketplace(hash)
    end

    module Helper

      module_function

      def available_domain_based_on(initial_domain)

        if initial_domain.blank?
          initial_domain = "trial_site"
        end

        current_domain = initial_domain.gsub(/[^A-Z0-9_]/i,"-").downcase
        current_domain = current_domain[0..29] #truncate to 30 chars or less

        # use basedomain as basis on new variations if current domain is not available
        base_domain = current_domain

        i = 1
        while CommunityModel.find_by_domain(current_domain) || RESERVED_DOMAINS.include?(current_domain) do
          current_domain = "#{base_domain}#{i}"
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
