module Admin
  module CategoryService
    class << self
      def move_custom_fields!(source_category, target_category)
        all_custom_fields = CategoryCustomField.find_by_category_and_subcategory(source_category)
        excluded_custom_field_ids = target_category.custom_fields.collect(&:id)

        custom_fields_to_move = if excluded_custom_field_ids.empty? 
          all_custom_fields
        else
          all_custom_fields.where("custom_field_id NOT IN (?)", excluded_custom_field_ids)
        end

        custom_fields_to_move.update_all(:category_id => target_category.id)
      end
    end
  end
end