ThinkingSphinx::Index.define :custom_field_value, :with => :active_record, :delta => ThinkingSphinx::Deltas::DelayedDelta do

  # attributes
  has listing_id
  has custom_field_id
  has numeric_value

end
