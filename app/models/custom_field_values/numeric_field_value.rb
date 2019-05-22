# == Schema Information
#
# Table name: custom_field_values
#
#  id              :integer          not null, primary key
#  custom_field_id :integer
#  listing_id      :integer
#  text_value      :text(65535)
#  numeric_value   :float(24)
#  date_value      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  type            :string(255)
#  delta           :boolean          default(TRUE), not null
#  person_id       :string(255)
#
# Indexes
#
#  index_custom_field_values_on_listing_id  (listing_id)
#  index_custom_field_values_on_person_id   (person_id)
#  index_custom_field_values_on_type        (type)
#

class NumericFieldValue < CustomFieldValue

  validates :numeric_value, numericality: true, if: proc { |numeric_field_value| numeric_field_value.question.required? }

  def display_value
    question.allow_decimals ? numeric_value : numeric_value.to_i
  end

  # See self._search_many
  # This is just dummy wrapper to log the execution time
  def self.search_many(with_many, ids=[])
    TimingService.log(0.5, "Searching with #{with_many.count} numeric fields took too long") {
      NumericFieldValue._search_many(with_many, ids)
    }
  end

  private

  # Recursive function that does multiple sphinx searches
  #
  # Give an array of filtering options and get back search results that
  # matches all the options
  #
  # Usage:
  # with_many = [{
  #   custom_field_id: board_length.id,
  #   numeric_value: (0..50)
  # }, {
  #   custom_field_id: board_width.id,
  #   numeric_value: (0..20)
  # }]
  #
  # NumericFieldValue.search_many(with_many) => search result
  #
  def self._search_many(with_many, ids=[])
    if with_many.length == 0
      NumericFieldValue.search_with_listing_ids({}, ids)
    elsif (with_many.length == 1)
      NumericFieldValue.search_with_listing_ids(with_many.first, ids)
    else
      first_with, *rest_withs = *with_many # http://devblog.avdi.org/2010/01/31/first-and-rest-in-ruby/
      new_ids = NumericFieldValue._search_many(rest_withs, ids).collect(&:listing_id)

      if new_ids.empty?
        # Stop searching, if nothing found
        new_ids
      else
        NumericFieldValue.search_with_listing_ids(first_with, new_ids)
      end
    end
  end

  def self.search_with_listing_ids(with, ids)
    NumericFieldValue.search(with: with.merge({listing_id: ids}), per_page: ListingIndexService::Search::SphinxAdapter::SPHINX_MAX_MATCHES)
  end
end
