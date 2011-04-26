# Extends class Tag from gem 'acts-as-taggable-on'
class Tag < ActiveRecord::Base

  def self.tags(options = {})
    query = "select tags.id, name, count(*) as count"
    query << " from taggings, tags, listings"
    query << " where tags.id = tag_id and listings.id = taggable_id"
    query << " and listing_type = '#{options[:listing_type]}'" if options[:listing_type] != nil
    query << " group by tag_id"
    query << " order by #{options[:order]}" if options[:order] != nil
    query << " limit #{options[:limit]}" if options[:limit] != nil
    tags = Tag.find_by_sql(query)
  end

end
