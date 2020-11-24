class Admin::CommunitySeoSettingsController < Admin::AdminBaseController
  before_action :find_or_initialize_customizations

  def show
    @community = @current_community
    @selected_left_navi_link = "seo"
  end

  def update
    meta_params = params.require(:community).permit(
      community_customizations_attributes: [
        :id,
        :meta_title,
        :meta_description,
        :search_meta_title,
        :search_meta_description,
        :listing_meta_title,
        :listing_meta_description,
        :profile_meta_title,
        :profile_meta_description,
        :category_meta_title,
        :category_meta_description,
      ]
    )
    @current_community.update(meta_params)
    redirect_to action: :show
  end

  private

  def find_or_initialize_customizations
    @current_community.locales.each do |locale|
      next if @current_community.community_customizations.find_by_locale(locale)

      @current_community.community_customizations.create(
        slogan: @current_community.slogan,
        description: @current_community.description,
        search_placeholder: t("homepage.index.what_do_you_need", locale: locale),
        locale: locale
      )
    end
  end
end
