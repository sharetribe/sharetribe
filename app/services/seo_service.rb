class SeoService


  # One can use the following variables as placeholders for SEO title and meta tags:
  #
  #   {{marketplace_name}} - the marketplace name
  #   {{marketplace_slogan}} - the marketplace slogan
  #   {{marketplace_description}} - the marketplace description
  #   {{keywords_searched}} - the keywords that were typed in the search field (if enabled/available)
  #   {{location_searched}} - the location that was typed/selected in the location search field (if enabled/available)
  #   {{listing_title}} - the listing title
  #   {{listing_author}} - the listing author title, according to the Display name preferences
  #   {{listing_price}} - the listing price + pricing unit (for example "$20 per person")
  #   {{category_name}} - the category name
  #   {{user_display_name}} - user display name


  # user, category and listing are set in appropriate controllers
  attr_accessor :user, :category, :listing
  attr_reader :locale

  def initialize(community, params = {})
    @community = community
    @params = params
    @locale = I18n.locale
  end

  def i18n_variables(section)
    vars = variables(section).map{|varname| '{{'+varname+'}}' }
    I18n.t("seo_sections.you_can_use_variables", vars: vars.join(", "))
  end

  def placeholder(section, locale = I18n.locale)
    case section
    when :homepage_title
      '{{marketplace_name}} - {{marketplace_slogan}}'
    when :homepage_description
      '{{marketplace_description}} - {{marketplace_slogan}}'
    when :search_meta_title
      I18n.t("seo_sections.placeholder.search_results", variable: '{{marketplace_name}}', locale: locale)
    when :search_meta_description
      I18n.t("seo_sections.placeholder.search_results_for", placeholder1: '{{keywords_searched}} {{location_searched}}', placeholder2: '{{marketplace_name}}', locale: locale)
    when :listing_meta_title
      '{{listing_title}} - {{marketplace_name}}'
    when :listing_meta_description
      if mode == 'default' || @listing.try(:price_cents).to_i > 0
        I18n.t("seo_sections.placeholder.listing_description", title: '{{listing_title}}', price: '{{listing_price}}', author: '{{listing_author}}', marketplace: '{{marketplace_name}}', locale: locale)
      else
        I18n.t("seo_sections.placeholder.listing_description_without_price", title: '{{listing_title}}', author: '{{listing_author}}', marketplace: '{{marketplace_name}}', locale: locale)
      end
    when :category_meta_title
      '{{category_name}} - {{marketplace_name}}'
    when :category_meta_description
      I18n.t("seo_sections.placeholder.category_description", category: '{{category_name}}', marketplace: '{{marketplace_name}}', locale: locale)
    when :profile_meta_title
      I18n.t("seo_sections.placeholder.profile_title", user: '{{user_display_name}}', marketplace: '{{marketplace_name}}', locale: locale)
    when :profile_meta_description
      I18n.t("seo_sections.placeholder.profile_description", user: '{{user_display_name}}', marketplace: '{{marketplace_name}}', locale: locale)
    end
  end

  def title(default_value, extra_mode = nil, locale = I18n.locale)
    return @title if defined?(@title)

    @locale = locale
    custom_value =
      if mode == 'default' && extra_mode == :social
        # social media title is passed here from layout
        default_value
      elsif customization.present?
        customization_title(mode)
      else
        default_value
      end
    @title = custom_value.present? ? interpolate(custom_value, locale) : default_value
  end

  def description(default_value, extra_mode = nil, locale = I18n.locale)
    return @description if defined?(@description)

    @locale = locale
    custom_value =
      if mode == 'default' && extra_mode == :social
        # social media description is passed here from layout
        default_value
      elsif customization.present?
        customization_description(mode)
      else
        default_value
      end
    @description = custom_value.present? ? interpolate(custom_value, locale) : default_value
  end

  def interpolate(text, locale = I18n.locale)
    text.to_s.gsub(/\{\{(\w+?)\}\}/) do |s|
      eval_single(Regexp.last_match[1], locale)
    end
  end

  private

  def customization
    @customization ||= @community.community_customizations.find_by(locale: locale)
  end

  def mode
    @mode ||= mode_from_params
  end

  def mode_from_params
    if @params.blank?
      'default'
    elsif @params[:action] == 'index' && @params[:controller] == 'homepage'
      if @params[:q].present? || @params[:lq].present?
        'search'
      elsif @params[:category].present?
        'category'
      else
        'homepage'
      end
    elsif @params[:action] == 'show' && @params[:controller] == 'people'
      'profile'
    elsif @params[:action] == 'show' && @params[:controller] == 'listings'
      'listing'
    else
      'default'
    end
  end

  def variables(section)
    case section
    when :homepage_title, :homepage_description
      ['marketplace_name', 'marketplace_slogan', 'marketplace_description']
    when :search_meta_title, :search_meta_description
      ['marketplace_name', 'marketplace_slogan', 'marketplace_description', 'keywords_searched', 'location_searched']
    when :listing_meta_title, :listing_meta_description
      ['marketplace_name', 'marketplace_slogan', 'marketplace_description', 'listing_title', 'listing_author', 'listing_price']
    when :category_meta_title, :category_meta_description
      ['marketplace_name', 'marketplace_slogan', 'marketplace_description', 'category_name']
    when :profile_meta_title, :profile_meta_description
      ['marketplace_name', 'marketplace_slogan', 'marketplace_description', 'user_display_name']
    end
  end

  def eval_single(variable, locale = I18n.locale)
    case variable
    when 'marketplace_name'
      @community.name(locale)
    when 'marketplace_description'
      community_description(locale)
    when 'marketplace_slogan'
      community_slogan(locale)
    when 'keywords_searched'
      @params ? @params[:q] : nil
    when 'location_searched'
      @params ? @params[:lq] : nil
    when 'listing_title'
      @listing ? @listing.title : nil
    when 'listing_author'
      @listing ? PersonViewUtils.person_display_name(@listing.author, @community) : nil
    when 'listing_price'
      if @listing&.price
        if @listing.unit_type
          [
            MoneyViewUtils.to_humanized(@listing.price),
            I18n.t("listings.show.price.per_quantity_unit", quantity_unit: ListingViewUtils.translate_unit(listing.unit_type, listing.unit_tr_key, locale: locale))
          ].join(" ")
        else
          MoneyViewUtils.to_humanized(@listing.price)
        end
      end
    when 'category_name'
      @category ? @category.display_name(locale) : nil
    when 'user_display_name'
      @user ? PersonViewUtils.person_display_name(@user, @community) : nil
    end
  end

  def community_slogan(locale)
    customization = @community.community_customizations.where(locale: locale).first
    if customization&.slogan.present?
      customization.slogan
    elsif @community.slogan.present?
      @community.slogan
    else
      I18n.t("common.default_community_slogan")
    end
  end

  def community_description(locale)
    customization = @community.community_customizations.where(locale: locale).first
    if customization&.description.present?
      customization.description
    elsif @community.description.present?
      @community.description
    else
      I18n.t("common.default_community_description")
    end
  end

  def customization_title(mode)
    case mode
    when 'homepage'
      customization.meta_title
    when 'listing'
      customization_value_or_default(:listing_meta_title)
    when 'profile'
      customization_value_or_default(:profile_meta_title)
    when 'search'
      customization_value_or_default(:search_meta_title)
    when 'category'
      customization_value_or_default(:category_meta_title)
    end
  end

  def customization_description(mode)
    case mode
    when 'homepage'
      customization.meta_description
    when 'listing'
      customization_value_or_default(:listing_meta_description)
    when 'profile'
      customization_value_or_default(:profile_meta_description)
    when 'search'
      customization_value_or_default(:search_meta_description)
    when 'category'
      customization_value_or_default(:category_meta_description)
    end
  end

  def customization_value_or_default(feature)
    value = customization.send(feature)
    value.presence || placeholder(feature, locale)
  end
end
