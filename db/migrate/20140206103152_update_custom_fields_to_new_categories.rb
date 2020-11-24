class UpdateCustomFieldsToNewCategories < ActiveRecord::Migration
  def up
    CategoryCustomField.find_each do |cat_custom_field|
      old_category = cat_custom_field.category
      community = cat_custom_field.custom_field.community
      new_category = Category.find_by_community_id_and_name(community.id, old_category.name)
      if new_category.nil?
        puts "***ERROR*** Can't find new category (#{old_category.name}) for community (#{community.id}) - SKIPPING updating cat_cust_f (#{cat_custom_field.id})"
      else
        puts "Updating custom field (#{cat_custom_field.custom_field.id}) to be linked from cat (#{old_category.id}) to cat (#{new_category.id})"
        cat_custom_field.update_column(:category_id, new_category.id)  
      end
      
      
    end
  end

  def down
    CategoryCustomField.find_each do |cat_custom_field|
      old_category = cat_custom_field.category
      community = cat_custom_field.custom_field.community
      new_category = Category.find_by_community_id_and_name(nil, old_category.name)
      if new_category.nil?
        puts "***ERROR*** Can't find new category (#{old_category.name}) for community (#{community.id}) - SKIPPING updating cat_cust_f (#{cat_custom_field.id})"
      else
        puts "Updating custom field (#{cat_custom_field.custom_field.id}) to be linked from cat (#{old_category.id}) to cat (#{new_category.id})"
        cat_custom_field.update_column(:category_id, new_category.id)  
      end
      
      
    end

  end
end
