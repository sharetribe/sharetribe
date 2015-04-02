module CategoryViewUtils

  module_function

  # Returns an array that contains the hierarchy of categories and transaction types
  #
  # An xample of a returned tree:
  #
  # [
  #   {
  #     "label" => "item",
  #     "id" => id,
  #     "subcategories" => [
  #       {
  #         "label" => "tools",
  #         "id" => id,
  #         "transaction_types" => [
  #           {
  #             "label" => "sell",
  #             "id" => id
  #           }
  #         ]
  #       }
  #     ]
  #   },
  #   {
  #     "label" => "services",
  #     "id" => "id"
  #   }
  # ]
  def category_tree(category_models:, shape_entities:, association_models:, locale:, all_locales:, community_translations:)
    category_models.map { |category_model|
      current_category = {
        id: category_model.id,
        label: category_model.display_name(locale)
      }

      additional_fields =
        if category_model.children.empty?
          {
            transaction_types: select_shapes(
              category_model: category_model,
              shape_entities: shape_entities,
              association_models: association_models
            ).map { |s|
              {
                id: s[:transaction_type_id],
                label: TranslationServiceHelper.pick_translation(
                  s[:name_tr_key],
                  community_translations,
                  all_locales,
                  locale)
              }
            }
          }
        else
          {
            # do recursion
            subcategories: CategoryViewUtils.category_tree(
              category_models: category_model.children,
              shape_entities: shape_entities,
              association_models: association_models,
              all_locales: all_locales,
              locale: locale,
              community_translations: community_translations
            )
          }
        end

      current_category.merge(additional_fields)
    }
  end

  # private

  def select_shapes(category_model:, shape_entities:, association_models:)
    association_models.select { |assoc|
      category_model.id == assoc.category_id
    }.map { |assoc|
      shape_entities.find { |s| s[:id] == assoc.listing_shape_id }
    }
  end
end
