module TranslationService
  module DataTypes

    module Translation
      FindParams = EntityUtils.define_builder(
        [:translation_keys, :array, default: []],
        [:locales, :array, default: []],
        [:fallback_locale, :string])

      CreateTranslationGroups = EntityUtils.define_builder(
        [:translation_groups, :array, default: []])

      CreateTranslationGroup = EntityUtils.define_builder(
        [:translations, :mandatory, :array],
        [:translation_key, :string])

      CreateTranslation = EntityUtils.define_builder(
        [:locale, :mandatory, :string],
        [:translation, :mandatory, :string],
        [:translation_key, :string])

      DeleteParams = EntityUtils.define_builder(
        [:translation_keys, :array, default: []])


      module_function

      def validate_find_params(opts); FindParams.call(opts) end

      def validate_translation_groups(opts)
        groups = CreateTranslationGroups.call(opts)
        groups[:translation_groups].map { |g|

          group = CreateTranslationGroup.call(g)
          group[:translations].map { |translation|
            CreateTranslation.call(translation)
          }
          group
        }
        groups
      end

      def validate_delete_params(opts); DeleteParams.call(opts) end

    end

  end
end
