class NumericFieldValue < CustomFieldValue
  attr_accessible :numeric_value
  validates_numericality_of :numeric_value

  # See self._search_many
  # This is just dummy wrapper to log the execution time
  def self.search_many(with_many, ids=[])
    beginning_time = Time.now
    result = NumericFieldValue._search_many(with_many, ids)
    end_time = Time.now

    total_time = end_time - beginning_time
    
    if (total_time > 0.5)
      logger.warn "Searching with #{with_many.count} numeric fields took too long: #{(end_time - beginning_time)*1000} milliseconds"
    end

    result
  end

  private

  # Recursive function that does multiple sphinx searches
  #
  # Give a array of filtering options and get back search results that
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
    NumericFieldValue.search(with: with.merge({listing_id: ids}))
  end
end