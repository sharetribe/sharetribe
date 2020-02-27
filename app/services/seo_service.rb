class SeoService


  # One can use the following variables as placeholders for SEO title and meta tags:

  VARIABLES = [
    MARKETPLACE_NAME = 'marketplace_name'.freeze, # the marketplace name
    MARKETPLACE_SLOGAN = 'marketplace_slogan'.freeze, # the marketplace slogan
    MARKETPLACE_DESCRIPTION = 'marketplace_description'.freeze, # the marketplace description
    KEYWORDS_SEARCHED = 'keywords_searched'.freeze, # the keywords that were typed in the search field (if enabled/available)
    LOCATION_SEARCHED = 'location_searched'.freeze, # the location that was typed/selected in the location search field (if enabled/available)
    LISTING_TITLE = 'listing_title'.freeze, # the listing title
    LISTING_AUTHOR = 'listing_author'.freeze, # the listing author title, according to the Display name preferences
    LISTING_PRICE = 'listing_price'.freeze, # the listing price + pricing unit (for example "$20 per person")
    CATEGORY_NAME = 'category_name'.freeze, # the category name
    USER_DISPLAY_NAME = 'user_display_name'.freeze, # user display name
  ].freeze


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
    when :homepage_title, :meta_title
      "{{#{MARKETPLACE_NAME}}} - {{#{MARKETPLACE_SLOGAN}}}"
    when :homepage_description, :meta_description
      "{{#{MARKETPLACE_DESCRIPTION}}} - {{#{MARKETPLACE_SLOGAN}}}"
    when :search_meta_title
      I18n.t("seo_sections.placeholder.search_results", variable: "{{#{MARKETPLACE_NAME}}}", locale: locale)
    when :search_meta_description
      I18n.t("seo_sections.placeholder.search_results_for", placeholder1: "{{#{KEYWORDS_SEARCHED}}} {{#{LOCATION_SEARCHED}}}", placeholder2: "{{#{MARKETPLACE_NAME}}}", locale: locale)
    when :listing_meta_title
      "{{#{LISTING_TITLE}}} - {{#{MARKETPLACE_NAME}}}"
    when :listing_meta_description
      if mode == 'default' || @listing.try(:price_cents).to_i > 0
        I18n.t("seo_sections.placeholder.listing_description", title: "{{#{LISTING_TITLE}}}", price: "{{#{LISTING_PRICE}}}", author: "{{#{LISTING_AUTHOR}}}", marketplace: "{{#{MARKETPLACE_NAME}}}", locale: locale)
      else
        I18n.t("seo_sections.placeholder.listing_description_without_price", title: "{{#{LISTING_TITLE}}}", author: "{{#{LISTING_AUTHOR}}}", marketplace: "{{#{MARKETPLACE_NAME}}}", locale: locale)
      end
    when :category_meta_title
      "{{#{CATEGORY_NAME}}} - {{#{MARKETPLACE_NAME}}}"
    when :category_meta_description
      I18n.t("seo_sections.placeholder.category_description", category: "{{#{CATEGORY_NAME}}}", marketplace: "{{#{MARKETPLACE_NAME}}}", locale: locale)
    when :profile_meta_title
      I18n.t("seo_sections.placeholder.profile_title", user: "{{#{USER_DISPLAY_NAME}}}", marketplace: "{{#{MARKETPLACE_NAME}}}", locale: locale)
    when :profile_meta_description
      I18n.t("seo_sections.placeholder.profile_description", user: "{{#{USER_DISPLAY_NAME}}}", marketplace: "{{#{MARKETPLACE_NAME}}}", locale: locale)
    end
  end

  def title(default_value, extra_mode = nil, locale = I18n.locale)
    @locale = locale
    custom_value =
      if mode == 'default' && extra_mode == :social
        # social media title is passed here from layout
        default_value
      elsif customization.present?
        customization_title(mode, extra_mode)
      else
        default_value
      end
    @title = custom_value.present? ? interpolate(custom_value, locale) : default_value
  end

  def description(default_value, extra_mode = nil, locale = I18n.locale)
    @locale = locale
    custom_value =
      if mode == 'default' && extra_mode == :social
        # social media description is passed here from layout
        default_value
      elsif customization.present?
        customization_description(mode, extra_mode)
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

  def variables(section)
    case section
    when :homepage_title, :homepage_description
      [MARKETPLACE_NAME, MARKETPLACE_SLOGAN, MARKETPLACE_DESCRIPTION]
    when :search_meta_title, :search_meta_description
      [MARKETPLACE_NAME, MARKETPLACE_SLOGAN, MARKETPLACE_DESCRIPTION, KEYWORDS_SEARCHED, LOCATION_SEARCHED]
    when :listing_meta_title, :listing_meta_description
      [MARKETPLACE_NAME, MARKETPLACE_SLOGAN, MARKETPLACE_DESCRIPTION, LISTING_TITLE, LISTING_AUTHOR, LISTING_PRICE]
    when :category_meta_title, :category_meta_description
      [MARKETPLACE_NAME, MARKETPLACE_SLOGAN, MARKETPLACE_DESCRIPTION, CATEGORY_NAME]
    when :profile_meta_title, :profile_meta_description
      [MARKETPLACE_NAME, MARKETPLACE_SLOGAN, MARKETPLACE_DESCRIPTION, USER_DISPLAY_NAME]
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

  def eval_single(variable, locale = I18n.locale)
    case variable
    when MARKETPLACE_NAME
      @community.name(locale)
    when MARKETPLACE_DESCRIPTION
      community_description(locale)
    when MARKETPLACE_SLOGAN
      community_slogan(locale)
    when KEYWORDS_SEARCHED
      @params ? @params[:q] : nil
    when LOCATION_SEARCHED
      @params ? @params[:lq] : nil
    when LISTING_TITLE
      @listing ? @listing.title : nil
    when LISTING_AUTHOR
      @listing ? PersonViewUtils.person_display_name(@listing.author, @community) : nil
    when LISTING_PRICE
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
    when CATEGORY_NAME
      @category ? @category.display_name(locale) : nil
    when USER_DISPLAY_NAME
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

  def customization_title(mode, extra_mode = nil)
    case mode
    when 'homepage'
      if extra_mode == :social
        customization.social_media_title.presence || placeholder(:meta_title, locale)
      else
        customization_value_or_default(:meta_title)
      end
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

  def customization_description(mode, extra_mode = nil)
    case mode
    when 'homepage'
      if extra_mode == :social
        customization.social_media_description.presence || placeholder(:meta_description, locale)
      else
        customization_value_or_default(:meta_description)
      end
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
