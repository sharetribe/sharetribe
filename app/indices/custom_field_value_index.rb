ThinkingSphinx::Index.define :custom_field_value, :with => :active_record, :delta => ThinkingSphinx::Deltas::DelayedDelta do

  #Thinking Sphinx will automatically add the SQL command SET NAMES utf8 as
  # part of the indexing process if the database connection settings have
  # encoding set to utf8. This is default in Rails but with Heroku, we need to
  # be explicit.
  set_property :utf8? => true

  # attributes
  has listing_id
  has custom_field_id
  has numeric_value

end
