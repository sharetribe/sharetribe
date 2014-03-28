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

      # Give all current `categories` and `category_to_be_merged`
      # and get back all the possible merge targets
      #
      # ## Examle category structure:
      #
      # Category A
      # - Subcategory A1
      # Category B
      # Category C
      # - Subcategory C1
      # - Subcategory C2
      #
      # Merge targets for:
      # A  => B, C1, C2
      # A1 => A, B, C1, C2
      # B  => A, A1, C1, C2
      # C  => A, A1, B
      # C1 => A, A1, B, C, C2
      # C2 => A, A1, B, C, C1
      #
      def merge_targets_for(categories, category_to_be_merged)
        categories
          .reject { |c| c == category_to_be_merged }                    # reject self
          .reject { |c| category_to_be_merged.children.include?(c) }    # reject own children (if any)
          .select { |c| (c.children - [category_to_be_merged]).empty? } # take "leaves" but include own parent (which is soon to be leaf)
      end
    end
  end
end
