module NewLayoutViewUtils
  extend ActionView::Helpers::TranslationHelper

  Feature = EntityUtils.define_builder(
    [:title, :string, :mandatory],
    [:name, :symbol, :mandatory],
    [:enabled_for_user, :bool, :mandatory],
    [:enabled_for_community, :bool, :mandatory],
    [:required_for_user, :bool, default: false],
    [:required_for_community, :bool, default: false]
  )

  # Describes feature relationships:
  # { feature: :required }
  FEATURE_RELS = {
    searchpage_v1: :topbar_v1
  }

  module_function

  # Returns data structure describing features that are manageable to
  # all admins
  def published_features
   [
    { title: t("admin.communities.new_layout.new_topbar"),
      name: :topbar_v1
    },
   ]
  end

  # Returns a hash describing experimental features. Returned hash
  # maps a feature flag to a feature description. If the key feature
  # flag is enabled for user or community, the value becomes
  # manageable in admin ui.
  def experimental_features
    {
      manage_searchpage: {
        title: t("admin.communities.new_layout.searchpage"),
        name:  :searchpage_v1,
      },
    }
  end

  def features(community_id, person_id, private_community, clp_enabled)
    person_flags = FeatureFlagService::API::Api.features.get_for_person(community_id: community_id, person_id: person_id).data[:features]
    community_flags = FeatureFlagService::API::Api.features.get_for_community(community_id: community_id).data[:features]

    fs = all_features(person_flags, community_flags, private_community, clp_enabled)

    fs.map { |f|
      Feature.build({
        title: f[:title],
        name: f[:name],
        enabled_for_user: person_flags.include?(f[:name]),
        enabled_for_community: community_flags.include?(f[:name]),
        required_for_user: flag_required?(f, person_flags),
        required_for_community: flag_required?(f, community_flags)
      })}
  end

  # Takes a map of features
  # {
  #  "foo" => "true",
  #  "bar" => "true",
  # }
  # and returns the keys as symbols from the entries
  # that hold value "true".
  def enabled_features(feature_params)
    allowed_features = (published_features + experimental_features.values).map { |f| f[:name] }
    features = feature_params.select { |key, value| value == "true" }
                 .keys
                 .map(&:to_sym)
                 .select { |k| allowed_features.include?(k) }
    add_required_features(features)
  end

  # From the list of features, selects the ones
  # that are disabled, ie. not included in the
  # list of enabled features.
  def resolve_disabled(enabled)
     all_enabled = add_required_features(enabled)
     features = (published_features + experimental_features.values).map { |f| f[:name]}
       .select { |f| !all_enabled.include?(f) }
  end

  # private

  def add_required_features(features)
    (features | FEATURE_RELS.values_at(*features)).compact
  end


  def all_features(person_flags, community_flags, private_community, clp_enabled)
    all_flags = (person_flags | community_flags).to_a

    # Additional rules for flags
    all_flags.delete(:searchpage_v1) unless can_manage_searchpage?(all_flags, private_community, clp_enabled)

    (published_features + experimental_features.values_at(*all_flags)).compact
  end

  def can_manage_searchpage?(flags, private_community, clp_enabled)
    flags.include?(:manage_searchpage) && !private_community || clp_enabled
  end

  def flag_required?(fl, flags)
    # If the required flag is provided in flags, the requirement must be enabled
    flags.include?(FEATURE_RELS.key(fl[:name]))
  end
end
