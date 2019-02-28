module LayoutHelper

  # Get a local variable. This is useful in layouts, since locals are not available
  # in them by default.
  #
  # Behaves like local variables, i.e. throws if variable is not available
  #
  # See more http://stackoverflow.com/questions/7382496/how-to-pass-a-variable-to-a-layout
  #
  def locals(local_assigns, key)
    raise "Local variable '#{key}' is not available." unless local_assigns.has_key?(key)

    local_assigns[key]
  end

  def social_media_title
    customization = @current_community.community_customizations.where(locale: I18n.locale).first
    if customization&.social_media_title.present?
      customization.social_media_title
    else
      "#{@current_community.full_name(I18n.locale)} - #{community_slogan}"
    end
  end

  def social_media_description
    customization = @current_community.community_customizations.where(locale: I18n.locale).first
    if customization&.social_media_description.present?
      customization.social_media_description
    else
      "#{community_description(false)} - #{community_slogan}"
    end
  end

  def custom_meta_title(default, extra_mode = nil)
    @seo_service.title(default, extra_mode)
  end

  def custom_meta_description(default, extra_mode = nil)
    @seo_service.description(default, extra_mode)
  end
end
