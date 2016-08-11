module FeatureFlagService::Store

  class FeatureFlag
    FeatureFlagModel = ::FeatureFlag

    CommunityFlag = EntityUtils.define_builder(
      [:community_id, :fixnum, :mandatory],
      [:features, :mandatory, :set])

    PersonFlag = EntityUtils.define_builder(
      [:person_id, :string, :mandatory],
      [:features, :mandatory, :set])

    CombinedFlag = EntityUtils.define_builder(
      [:community_id, :fixnum, :mandatory],
      [:person_id, :string, :mandatory],
      [:features, :mandatory, :set])

    FLAGS = [
      :export_transactions_as_csv,
      :topbar_v1,
    ].to_set

    def initialize(additional_flags:)
      @additional_flags = additional_flags.to_set
    end

    def known_flags
      FLAGS.dup.merge(@additional_flags)
    end

    def get(community_id, person_id)
      Maybe(FeatureFlagModel.where("community_id = ? AND (person_id IS NULL OR person_id = ?)", community_id, person_id))
        .map { |features|
          from_combined_models(community_id, person_id, features)
        }.or_else(no_combined_flags(community_id, person_id))
    end

    def get_by_community_id(community_id)
      Maybe(FeatureFlagModel.where(community_id: community_id, person_id: nil))
        .map { |features|
          from_community_models(community_id, features)
        }.or_else(no_community_flags(community_id))
    end

    def get_by_person_id(person_id)
      Maybe(FeatureFlagModel.where(person_id: person_id))
        .map { |features|
          from_person_models(person_id, features)
        }.or_else(no_person_flags(person_id))
    end

    def enable(community_id, person_id, features)
      flags_to_enable = known_flags.intersection(features).map { |flag| [flag, true] }.to_h
      update_flags!(community_id, person_id, flags_to_enable)

      if person_id
        get_by_person_id(person_id)
      else
        get_by_community_id(community_id)
      end
    end

    def disable(community_id, person_id, features)
      flags_to_disable = known_flags.intersection(features).map { |flag| [flag, false] }.to_h
      update_flags!(community_id, person_id, flags_to_disable)

      if person_id
        get_by_person_id(person_id)
      else
        get_by_community_id(community_id)
      end
    end


    private

    def from_combined_models(community_id, person_id, feature_models)
      CombinedFlag.call(
        community_id: community_id,
        person_id: person_id,
        features: feature_models.select { |m| known_flags.include?(m.feature.to_sym) && m.enabled }
          .map { |m| m.feature.to_sym }
          .to_set)
    end

    def from_community_models(community_id, feature_models)
      CommunityFlag.call(
        community_id: community_id,
        features: feature_models.select { |m| known_flags.include?(m.feature.to_sym) && m.enabled }
          .map { |m| m.feature.to_sym }
          .to_set)
    end

    def from_person_models(person_id, feature_models)
      PersonFlag.call(
        person_id: person_id,
        features: feature_models.select { |m| known_flags.include?(m.feature.to_sym) && m.enabled }
          .map { |m| m.feature.to_sym }
          .to_set)
    end

    def no_combined_flags(community_id, person_id)
      CombinedFlag.call(community_id: community_id, person_id: person_id, features: Set.new)
    end

    def no_community_flags(community_id)
      CommunityFlag.call(community_id: community_id, features: Set.new)
    end

    def no_person_flags(person_id)
      PersonFlag.call(person_id: person_id, features: Set.new)
    end

    def update_flags!(community_id, person_id, flags)
      flags.each { |feature, enabled|
        FeatureFlagModel
          .where(community_id: community_id, person_id: person_id, feature: feature)
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

    def get(community_id, person_id)
      Rails.cache.fetch(cache_key(community_id: community_id, person_id: person_id)) do
        @feature_flag_store.get(community_id, person_id)
      end
    end

    def get_by_community_id(community_id)
      Rails.cache.fetch(cache_key(community_id: community_id)) do
        @feature_flag_store.get_by_community_id(community_id)
      end
    end

    def get_by_person_id(person_id)
      Rails.cache.fetch(cache_key(person_id: person_id)) do
        @feature_flag_store.get_by_person_id(person_id)
      end
    end

    def enable(community_id, person_id, features)
      Rails.cache.delete(cache_key(community_id: community_id, person_id: person_id))
      @feature_flag_store.enable(community_id, person_id, features)
    end

    def disable(community_id, person_id, features)
      Rails.cache.delete(cache_key(community_id: community_id, person_id: person_id))
      @feature_flag_store.disable(community_id, person_id, features)
    end


    private

    def cache_key(community_id: nil, person_id: nil)
      raise ArgumentError.new("You must specify a valid community_id or person_id.") unless community_id || person_id

      id =
        if person_id && community_id
          "#{community_id}-#{person_id}"
        elsif person_id
          person_id
        else
          community_id
        end
      "/feature_flag_service/#{id}"
    end
  end
end
