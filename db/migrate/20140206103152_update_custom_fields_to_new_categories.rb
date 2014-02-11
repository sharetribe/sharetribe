class UpdateCustomFieldsToNewCategories < ActiveRecord::Migration
  def up
    CustomField.find_each do |custom_field|
      old_category = custom_field.category
      community = custom_field.community
      new_category = Category.find_by_community_id_and_name(community.id, old_category.name)
      if new_category.nil?
        puts "***ERROR*** Can't find new category (#{old_category.name}) for community (#{community.id}) - SKIPPING"
      else
        puts "Updating custom field (#{custom_field.id}) to be linked from cat (#{old_category.id}) to cat (#{new_category.id})"
        custom_field.update_column(:category_id, new_category.id)  
      end
      
      
    end
  end

  def down
    raise  ActiveRecord::IrreversibleMigration, "Down hasn't been implemented for this, as it hasn't been needed."
  end
end
