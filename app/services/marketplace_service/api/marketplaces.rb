module MarketplaceService::API

  module Marketplaces
    CommunityModel = ::Community

    RESERVED_DOMAINS = %w(www home sharetribe login blog catch webhooks dashboard dashboardtranslate translate community wiki mail secure host feed feeds app beta-site)

    module_function

    def create(params)
      p = Maybe(params)

      locale = p[:marketplace_language].or_else("en")
      marketplace_name = p[:marketplace_name].or_else("Trial Marketplace")

      community = CommunityModel.create(Helper.community_params(p, marketplace_name, locale, p[:paypal_enabled].or_else(false)))

      Helper.create_community_customization!(community, marketplace_name, locale)
      t = Helper.create_transaction_type!(community, p[:marketplace_type])
      Helper.create_category!("Default", community, locale, t.id)

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

      def community_params(params, marketplace_name, locale, paypal_enabled)
        {
          consent: "SHARETRIBE1.0",
          domain: available_domain_based_on(params[:marketplace_name].get),
          settings: {"locales" => [locale]},
          name: marketplace_name,
          available_currencies: available_currencies_based_on(params[:marketplace_country].or_else("us")),
          country: params[:marketplace_country].upcase.or_else(nil),
          paypal_enabled: paypal_enabled
        }
      end

      def customization_params(marketplace_name, locale)
        {
          name: marketplace_name,
          locale: locale,
          how_to_use_page_content: how_to_use_page_default_content(locale, marketplace_name)
        }
      end

      def create_transaction_type!(community, marketplace_type)
        transaction_type_name = transaction_type_name(marketplace_type)
        TransactionTypeCreator.create(community, transaction_type_name)
      end

      def create_community_customization!(community, marketplace_name, locale)
        community.community_customizations.create(customization_params(marketplace_name, locale))
      end

      def transaction_type_name(type)
       case type.or_else("product")
        when "rental"
          "Rent"
        when "service"
          "Service"
        else # also "product" goes to this default
          "Sell"
        end
      end

      def how_to_use_page_default_content(locale, marketplace_name)
        "<h1>#{I18n.t("infos.how_to_use.default_title", locale: locale)}</h1><div>#{I18n.t("infos.how_to_use.default_content", locale: locale, :marketplace_name => marketplace_name)}</div>"
      end

      def available_domain_based_on(initial_domain)

        if initial_domain.blank?
          initial_domain = "trial_site"
        end

        current_domain = initial_domain.to_url
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

      def create_category!(category_name, community, locale, transaction_type_id=nil)
        category = Category.create!(:community_id => community.id, :url => category_name.downcase)
        CategoryTranslation.create!(:category_id => category.id, :locale => locale, :name => category_name)

        if transaction_type_id
          CategoryTransactionType.create!(:category_id => category.id, :transaction_type_id => transaction_type_id)
        end
      end

    end

  end

end
