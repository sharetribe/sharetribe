module FeatureFlagService::Store

  class FeatureFlag
    FeatureFlagModel = ::FeatureFlag

    CommunityFlags = EntityUtils.define_builder(
      [:community_id, :fixnum, :mandatory],
      [:features, :mandatory, :set])

    FLAGS = [
      :export_transactions_as_csv,
      :onboarding_redesign_v1,
      :topbar_v1
    ].to_set

    def initialize(additional_flags:)
      @additional_flags = additional_flags.to_set
    end

    def known_flags
      FLAGS.dup.merge(@additional_flags)
    end

    def get(community_id)
      Maybe(FeatureFlagModel.where(community_id: community_id))
        .map { |features| from_models(community_id, features) }
        .or_else(no_flags(community_id))
    end

    def enable(community_id, features)
      flags_to_enable = known_flags.intersection(features).map { |flag| [flag, true] }.to_h
      update_flags!(community_id, flags_to_enable)

      get(community_id)
    end

    def disable(community_id, features)
      flags_to_disable = known_flags.intersection(features).map { |flag| [flag, false] }.to_h
      update_flags!(community_id, flags_to_disable)

      get(community_id)
    end


    private

    def from_models(community_id, feature_models)
      CommunityFlags.call(
        community_id: community_id,
        features: feature_models.select { |m| known_flags.include?(m.feature.to_sym) && m.enabled }
          .map { |m| m.feature.to_sym }
          .to_set)
    end

    def no_flags(community_id)
      CommunityFlags.call(community_id: community_id, features: Set.new)
    end

    def update_flags!(community_id, flags)
      flags.each { |feature, enabled|
        FeatureFlagModel
          .where(community_id: community_id, feature: feature)
          .first_or_create
          .update_attributes(enabled: enabled)
      }
    end
  end


  class CachingFeatureFlag

    def initialize(additional_flags:)
      @feature_flag_store = FeatureFlag.new(additional_flags: additional_flags)
    end

    def known_flags
      @feature_flag_store.known_flags
    end

    def get(community_id)
      Rails.cache.fetch(cache_key(community_id)) do
        @feature_flag_store.get(community_id)
      end
    end

    def enable(community_id, features)
      Rails.cache.delete(cache_key(community_id))
      @feature_flag_store.enable(community_id, features)
    end

    def disable(community_id, features)
      Rails.cache.delete(cache_key(community_id))
      @feature_flag_store.disable(community_id, features)
    end


    private

    def cache_key(community_id)
      raise ArgumentError.new("You must specify a valid community_id.") if community_id.blank?
      "/feature_flag_service/community/#{community_id}"
    end
  end

end
