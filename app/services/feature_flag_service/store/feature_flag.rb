module FeatureFlagService::Store::FeatureFlag

  FeatureFlagModel = ::FeatureFlag

  CommunityFlags = EntityUtils.define_builder(
    [:community_id, :fixnum, :mandatory],
    [:features, :mandatory, :set])

  FLAGS = [:shape_ui].to_set

  module_function

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


  ## Privates

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
