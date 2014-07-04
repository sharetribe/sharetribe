ThinkingSphinx::Index.define :listing, :with => :active_record, :delta => ThinkingSphinx::Deltas::DelayedDelta do

  #Thinking Sphinx will automatically add the SQL command SET NAMES utf8 as
  # part of the indexing process if the database connection settings have
  # encoding set to utf8. This is default in Rails but with Heroku, we need to
  # be explicit.
  set_property :utf8? => true

  # limit to open listings
  where "open = '1' AND (valid_until IS NULL OR valid_until > now())"

  # fields
  indexes title
  indexes description
  indexes category.translations.name, :as => :category
  indexes custom_field_values(:text_value), :as => :custom_text_fields
  indexes origin_loc.google_address

  # attributes
  has id, :as => :listing_id # id didn't work without :as aliasing
  has price_cents
  has created_at, updated_at
  has sort_date
  has category(:id), :as => :category_id
  has transaction_type(:id), :as => :transaction_type_id
  has "privacy = 'public'", :as => :visible_to_everybody, :type => :boolean
  has communities(:id), :as => :community_ids
  has custom_dropdown_field_values.selected_options.id, :as => :custom_dropdown_field_options, :type => :integer, :multi => true
  has custom_checkbox_field_values.selected_options.id, :as => :custom_checkbox_field_options, :type => :integer, :multi => true

  set_property :enable_star => true

  set_property :field_weights => {
    :title       => 10,
    :category    => 8,
    :description => 3
  }

end
