module MarketplaceService
  RESERVED_DOMAINS = [
    "www",
    "www0",
    "www1",
    "www2",
    "www3",
    "www4",
    "www5",
    "www6",
    "www7",
    "www8",
    "www9",
    "www10",
    "wwww",
    "home",
    "sharetribe",
    "login",
    "blog",
    "business",
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
    "marketplaces",
    "masters",
    "marketplacemasters",
    "insights",
    "insight",
    "tips",
    "doc",
    "docs",
    "support",
    "team",
    "support-team",
    "help",
    "legal",
    "org",
    "net",
    "web",
    "intra",
    "intranet",
    "internal",
    "join",
    "job",
    "jobs",
    "career",
    "careers",
    "journey",
    "journeys",
    "webinar",
    "local",
    "marketplace-academy",
    "academy-proxy",
    "academy",
    "proxy",
    "preproduction",
    "staging",
    "demo",
    "plan",
    "plans",
    "customer",
    "customers",
    "subscription",
    "subscriptions",
    "client",
    "clients",
    "assets",
    "assets-origin",
    "assets-sharetribecom",
    "assets0",
    "assets1",
    "assets2",
    "assets3",
    "assets4",
    "assets5",
    "assets6",
    "assets7",
    "assets8",
    "assets9",
    "cdn",
    "cdn-origin",
    "cdn0",
    "cdn1",
    "cdn2",
    "cdn3",
    "cdn4",
    "cdn5",
    "cdn6",
    "cdn7",
    "cdn8",
    "cdn9",
    "flex",
    "api",
    "console",
    "custom",
    "core",
    "turnkey",
    "admin",
  ]

  module_function

  def create(params)
    p = Maybe(params)

    locale = p[:marketplace_language].or_else("en")
    marketplace_name = p[:marketplace_name].or_else("Trial Marketplace")
    payment_process = p[:payment_process].or_else(:preauthorize)
    distance_unit = p[:marketplace_country].map { |country| country == "US" ? :imperial : :metric }.or_else(:metric)
    limit_search_distance = false

    community = Community.create(community_params(p, marketplace_name, locale))

    create_community_customization!(community, marketplace_name, locale)
    create_category!("Default category", community, locale)
    create_processes!(community.id, payment_process)
    create_listing_shapes!(community, p[:marketplace_type])
    create_configurations!({
      community_id: community.id,
      main_search: :keyword,
      distance_unit: distance_unit,
      limit_search_distance: limit_search_distance
    })

    community
  end

  def set_locales(community, locales)
    default_locale = community.locales[0]
    community_name = community.name(default_locale)
    locales.each { |locale| first_or_create_community_customization!(community, community_name, locale) }

    # Replace removed locale with default for users of marketplace
    removed_locales = community.locales - locales
    if removed_locales.present?
      UserService::API::Users.replace_with_default_locale(community_id: community.id,
                                                          locales: removed_locales,
                                                          default_locale: locales.first)
    end

    settings = community.settings || {}
    settings["locales"] = locales
    community.settings = settings
    community.save!
  end

  def all_locales
    Sharetribe::SUPPORTED_LOCALES.map{ |l|
      {
        locale_key: l[:ident],
        locale_name: l[:name]
      }
    }
  end

  def community_params(params, marketplace_name, locale)
    ident = available_ident_based_on(marketplace_name)
    {
      consent: "SHARETRIBE1.0",
      ident: ident,
      settings: {"locales" => [locale]},
      currency: country_currency(params[:marketplace_country].or_else("us")),
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

  def create_processes!(community_id, default_payment_process)
    payment_process = default_payment_process.to_sym
    unless [:none, :preauthorize].include?(payment_process)
      raise ArgumentError.new("Unknown payment process: #{payment_process}")
    end

    [
      {author_is_seller: true, process: :none},
      {author_is_seller: false, process: :none},
      {author_is_seller: true, process: payment_process}
    ].to_set.map { |p|
      TransactionProcess.where(
        community_id: community_id,
        process: p[:process],
        author_is_seller: p[:author_is_seller]
      ).first_or_create
    }
  end

  def create_listing_shapes!(community, marketplace_type)
    TransactionTypeCreator.create(community, marketplace_type)
  end

  def create_community_customization!(community, marketplace_name, locale)
    community.community_customizations.create(customization_params(marketplace_name, locale))
  end

  def first_or_create_community_customization!(community, marketplace_name, locale)
    existing_customization = community.community_customizations.where(locale: locale).first
    community.community_customizations.create!(customization_params(marketplace_name, locale)) unless existing_customization
  end

  def how_to_use_page_default_content(locale, marketplace_name)
    "<h1>#{I18n.t('infos.how_to_use.default_title', locale: locale)}</h1><div>#{I18n.t('infos.how_to_use.default_content', locale: locale, :marketplace_name => marketplace_name)}</div>"
  end

  def available_ident_based_on(initial_ident)
    current_ident = Maybe(initial_ident).to_url[0..29].or_else("trial_site") #truncate to 30 chars or less

    # use basedomain as basis on new variations if current domain is not available
    base_ident = current_ident

    i = 1
    while Community.exists?(ident: current_ident) || RESERVED_DOMAINS.include?(current_ident)
      current_ident = "#{base_ident}#{i}"
      i += 1
    end

    return current_ident
  end

  def country_currency(country_code)
    Maybe(TransactionService::AvailableCurrencies::COUNTRY_CURRENCIES[country_code.upcase]).or_else("USD")
  end

  def create_category!(category_name, community, locale)
    translation = CategoryTranslation.new(:locale => locale, :name => category_name)
    community.categories.create!(:url => category_name.downcase, translations: [translation])
  end

  def create_configurations!(opts)
    MarketplaceConfigurations.create(opts)
  end
end
