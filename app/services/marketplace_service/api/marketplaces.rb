module MarketplaceService::API

  module Marketplaces
    CommunityModel = ::Community

    RESERVED_DOMAINS = [
      "www",
      "home",
      "sharetribe",
      "login",
      "blog",
      "catch",
      "webhooks",
      "dashboard",
      "dashboardtranslate",
      "translate",
      "community",
      "wiki",
      "mail",
      "secure",
      "host",
      "feed",
      "feeds",
      "app",
      "beta-site",
      "marketplace",
      "marketplacemasters",
      "insights",
      "insight",
      "tips",
      "doc",
      "support",
      "legal",
      "org",
      "net",
      "web",
      "intra",
      "intranet",
      "internal",
      "webinar"
    ]

    module_function

    def create(params)
      p = Maybe(params)

      locale = p[:marketplace_language].or_else("en")
      marketplace_name = p[:marketplace_name].or_else("Trial Marketplace")

      community = CommunityModel.create(Helper.community_params(p, marketplace_name, locale))

      Helper.create_community_customization!(community, marketplace_name, locale)
      t = Helper.create_transaction_type!(community, p[:marketplace_type])
      listing_shape = Helper.create_listing_shape!(community, p[:marketplace_type], t.id)
      Helper.create_category!("Default", community, locale, t.id, listing_shape.id)

      plan_level = p[:plan_level].or_else(CommunityPlan::FREE_PLAN)
      Helper.create_community_plan!(community, {plan_level: plan_level});

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

      def community_params(params, marketplace_name, locale)
        ident = available_ident_based_on(marketplace_name)
        {
          consent: "SHARETRIBE1.0",
          ident: ident,
          settings: {"locales" => [locale]},
          available_currencies: available_currencies_based_on(params[:marketplace_country].or_else("us")),
          country: params[:marketplace_country].upcase.or_else(nil)
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
        transaction_type = TransactionTypeCreator.create(community, transaction_type_name)
      end

      def create_listing_shape!(community, marketplace_type, transaction_type_id)
        default_opts = {
          price_enabled: true,
        }

        shape_opts =
          case marketplace_type
          when "rental"
            {
              name_key: "admin.transaction_types.rent",
              action_button_label_key: "admin.transaction_types.default_action_button_labels.rent",
              price_per: "day"
            }
          when "service"
            {
              name_key: "admin.transaction_types.service",
              action_button_label_key: "admin.transaction_types.default_action_button_labels.offer",
              price_per: "day"
            }
          else
            # product
            {
              name_key: "admin.transaction_types.sell",
              action_button_label_key: "admin.transaction_types.default_action_button_labels.sell",
              price_per: nil
            }
          end

        opts = default_opts.merge(price_per: shape_opts[:price_per])

        locale = community.locales.first.to_sym
        translation_opts =
          {
            locale: locale,
            name: I18n.t(shape_opts[:name_key], locale: locale),
            action_button_label: I18n.t(shape_opts[:action_button_label_key], locale: locale)
          }

        # Create shape
        listing_shape_opts = opts.merge(
          {
            transaction_type_id: transaction_type_id, # This is only temporary
            url: translation_opts[:name].to_url
          })

        shape = community.listing_shapes.create(listing_shape_opts)

        # Create process
        process = shape.create_transaction_process(process: :preauthorize)

        # Create translation
        process.translations.create(translation_opts)

        shape
      end

      def create_community_customization!(community, marketplace_name, locale)
        community.community_customizations.create(customization_params(marketplace_name, locale))
      end

      def create_community_plan!(community, options={})
        CommunityPlan.create({
          community_id: community.id,
          plan_level:   Maybe(options[:plan_level]).or_else(0),
          expires_at:   Maybe(options[:expires_at]).or_else(DateTime.now.change({ hour: 9, min: 0, sec: 0 }) + 31.days)
        })
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

      def available_ident_based_on(initial_ident)

        if initial_ident.blank?
          initial_ident = "trial_site"
        end

        current_ident = initial_ident.to_url
        current_ident = current_ident[0..29] #truncate to 30 chars or less

        # use basedomain as basis on new variations if current domain is not available
        base_ident = current_ident

        i = 1
        while CommunityModel.exists?(ident: current_ident) || RESERVED_DOMAINS.include?(current_ident) do
          current_ident = "#{base_ident}#{i}"
          i += 1
        end

        return current_ident
      end

      def available_currencies_based_on(country_code)
        Maybe(MarketplaceService::AvailableCurrencies::COUNTRY_CURRENCIES[country_code.upcase]).or_else("USD")
      end

      def create_category!(category_name, community, locale, transaction_type_id=nil, listing_shape_id=nil)
        category = Category.create!(:community_id => community.id, :url => category_name.downcase)
        CategoryTranslation.create!(:category_id => category.id, :locale => locale, :name => category_name)

        if transaction_type_id
          CategoryTransactionType.create!(:category_id => category.id, :transaction_type_id => transaction_type_id)
        end

        if listing_shape_id
          CategoryListingShape.create!(category_id: category.id, listing_shape_id: listing_shape_id)
        end

      end

    end

  end

end
