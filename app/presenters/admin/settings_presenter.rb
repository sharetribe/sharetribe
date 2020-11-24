class Admin::SettingsPresenter
  private

  attr_reader :service

  public

  delegate :community, :params, to: :service, prefix: false, allow_nil: false

  def initialize(service:)
    @service = service
  end

  def delete_confirmation
    community.ident
  end

  def can_delete_marketplace
    PlanService::API::Api.plans.get_current(community_id: community.id).data.try(:[], :features).try(:[], :deletable)
  end

  def main_search
    marketplace_configurations[:main_search]
  end

  def main_search_select_options
    @main_search_select_options ||= [:keyword, :location].concat(keyword_and_location)
      .map { |type|
        html_attrs = {}
        if !show_location? && type != :keyword
          html_attrs[:disabled] = 'disabled'
        end
        [SettingsViewUtils.search_type_translation(type), type, html_attrs]
      }
  end

  def distance_unit
    marketplace_configurations[:distance_unit]
  end

  def distance_unit_select_options
    @distance_unit_select_options ||= [
      [SettingsViewUtils.distance_unit_translation(:km), :metric],
      [SettingsViewUtils.distance_unit_translation(:miles), :imperial]
    ]
  end

  def limit_distance
    marketplace_configurations[:limit_search_distance]
  end

  def max_automatic_confirmation_after_days
    StripeHelper.stripe_active?(community.id) ? 90 : 100
  end

  def stripe_available?
    StripeHelper.stripe_available?(community)
  end

  def delete_redirect_url
    APP_CONFIG.community_not_found_redirect
  end

  private

  def location_search_available
    FeatureFlagHelper.location_search_available
  end

  def marketplace_configurations
    @marketplace_configurations ||= community.configuration
  end

  def keyword_and_location
    @keyword_and_location ||=
      if FeatureFlagService::API::Api.features.get_for_community(community_id: community.id).data[:features].include?(:topbar_v1)
        [:keyword_and_location]
      else
        []
      end
  end

  def show_location?
    @show_location ||= community.show_location?
  end
end
