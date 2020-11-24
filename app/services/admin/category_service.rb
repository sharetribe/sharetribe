module Admin
  module CategoryService
    class << self
      def move_custom_fields!(source_category, target_category)
        custom_fields_to_move = CategoryCustomField.find_by_category_and_subcategory(source_category)

        custom_fields_to_move.each { |category_custom_field|
          CategoryCustomField.where(category_id: target_category.id, custom_field_id: category_custom_field.custom_field_id).first_or_create
        }

        custom_fields_to_move.delete_all
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
