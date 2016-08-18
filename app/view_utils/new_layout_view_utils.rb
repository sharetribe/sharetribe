module NewLayoutViewUtils
  extend ActionView::Helpers::TranslationHelper

  Feature = EntityUtils.define_builder(
    [:title, :string, :mandatory],
    [:name, :symbol, :mandatory],
    [:enabled_for_user, :bool, :mandatory],
    [:enabled_for_community, :bool, :mandatory]
  )

  FEATURES = [
    { title: t("admin.communities.new_layout.new_topbar"),
      name: :topbar_v1
    },
  ]

  module_function

  def features(community_id, person_id)
    person_flags = FeatureFlagService::API::Api.features.get_for_person(community_id: community_id, person_id: person_id).data[:features]
    community_flags = FeatureFlagService::API::Api.features.get_for_community(community_id: community_id).data[:features]

    FEATURES.map { |f|
      Feature.build({
        title: f[:title],
        name: f[:name],
        enabled_for_user: person_flags.include?(f[:name]),
        enabled_for_community: community_flags.include?(f[:name])
      })
    }
  end

  # Takes a map of features
  # {
  #  "foo" => "true",
  #  "bar" => "true",
  # }
  # and returns the keys as symbols from the entries
  # that hold value "true".
  def enabled_features(feature_params)
    allowed_features = FEATURES.map { |f| f[:name] }
    feature_params.select { |key, value| value == "true" }
      .keys
      .map(&:to_sym)
      .select { |k| allowed_features.include?(k) }
  end

  # From the list of features, selects the ones
  # that are disabled, ie. not included in the
  # list of enabled features.
  def resolve_disabled(enabled)
    FEATURES.map { |f| f[:name]}
      .select { |f| !enabled.include?(f) }
  end
end
