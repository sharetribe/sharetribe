# This controller is parent for all controllers handling the admin area functions

class Admin2::AdminBaseController < ApplicationController
  layout 'layouts/admin'
  before_action :ensure_is_admin

  #Allow admin to access admin panel before email confirmation
  skip_before_action :cannot_access_without_confirmation

  private

  def setup_seo_service
    @seo_service = SeoService.new(@current_community, params)
  end

  def find_or_initialize_customizations_for_locale(locale)
    @current_community.community_customizations.find_by_locale(locale) || build_customization_with_defaults(locale)
  end

  def find_customizations
    @customizations = @current_community.community_customizations
                                        .where(locale: @current_community.locales)
  end

  def find_or_initialize_customizations(locales)
    locales.each_with_object({}) do |locale, customizations|
      customizations[locale] = find_or_initialize_customizations_for_locale(locale)
    end
  end
end
