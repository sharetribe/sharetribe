module FeatureFlagService::Store

  class FeatureFlag
    FeatureFlagModel = ::FeatureFlag

    CommunityFlags = EntityUtils.define_builder(
      [:community_id, :fixnum, :mandatory],
      [:features, :mandatory, :set])

    FLAGS = [:shape_ui].to_set

    def known_flags; FLAGS.dup end

    def get(community_id)
      Maybe(FeatureFlagModel.where(community_id: community_id).first)
        .map { |m| from_model(m) }
        .or_else(no_flags(community_id))
    end

    def enable(community_id, features)
      model = get_or_create(community_id)
      flags_to_enable = FLAGS.intersection(features).map { |flag| [flag, true] }.to_h
      model.update_attributes!(flags_to_enable)

      from_model(model)
    end

    def disable(community_id, features)
      model = get_or_create(community_id)
      flags_to_disable = FLAGS.intersection(features).map { |flag| [flag, false] }.to_h
      model.update_attributes!(flags_to_disable)

      from_model(model)
    end


    private

    def from_model(m)
      CommunityFlags.call(
        community_id: m.community_id,
        features: EntityUtils.model_to_hash(m)
          .select { |attr, val| FLAGS.include?(attr) && val == true }
          .map { |flag, _| flag }
          .to_set)
    end

    def no_flags(community_id)
      CommunityFlags.call(community_id: community_id, features: Set.new)
    end

    def get_or_create(community_id)
      Maybe(FeatureFlagModel.where(community_id: community_id).first)
        .or_else(FeatureFlagModel.new(community_id: community_id))
    end
  end


  class CachingFeatureFlag

    def initialize
      @feature_flag_store = FeatureFlag.new
    end

    def known_flags; @feature_flag_store.known_flags end

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
