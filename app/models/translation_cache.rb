# DEPRECATED: Use TranslationService instead
#
# Simplifies access to translations that are stored in database. Implements also caching.
#
# Usage:
#
# If you have a `model` which has association to `model.translations` and you'd like to
# translate the `action_button_value` to `fr`, do this:
#
# TranslationCache.new(model, :translations).translate('fr', :action_button_value)
#
class TranslationCache

  def initialize(model, translation_attr_sym, locale_attr_sym=nil)
    @model = model
    @translation_attr_sym = translation_attr_sym
    @locale_attr_sym = locale_attr_sym || :locale
  end

  def translate(locale, value_field_name_sym, default="")
    t = translations.find { |translation| translation.send(@locale_attr_sym) == locale.to_s } || translations.first # Fallback to first
    t ? t.send(value_field_name_sym) : default
  end

  private

  # Fetch from cache, but only if model has ID
  # A model may not have ID if it's newly created but not saved to DB
  def fetch_cache(cache_key, &block)
    if @model.id
      Rails.cache.fetch(cache_key) do
        block.call
      end
    else
      block.call
    end
  end

  def translations
    fetch_cache(cache_key) do
      @model.send(@translation_attr_sym).to_a.map { |model|
        serialize(model)
      }
    end.map { |cache_result|
      deserialize(cache_result, @model.class, @translation_attr_sym)
    }
  end

  def cache_key
    "/#{@model.class.name}/#{@model.id}/#{@translation_attr_sym.to_s}/#{@model.updated_at}"
  end

  def deserialize(cache_result, parent_class, attr_name)
    is_same_or_subclass_of = -> (expected) {
      -> (actual) {
        actual <= expected
      }
    }

    case [parent_class, attr_name]
    when matches([is_same_or_subclass_of.call(Category), :translations])
      CategoryTranslation.new(cache_result)
    when matches([is_same_or_subclass_of.call(CustomField), :names])
      CustomFieldName.new(cache_result)
    when matches([is_same_or_subclass_of.call(CustomFieldOption), :titles])
      CustomFieldOptionTitle.new(cache_result)
    when matches([is_same_or_subclass_of.call(MenuLink), :translations])
      MenuLinkTranslation.new(cache_result)
    else
      raise ArgumentError.new("Unknown parent_class '#{parent_class.name}' and attribute name '#{attr_name}' for cached translation")
    end
  end

  def serialize(model)
    model.attributes
  end

end
