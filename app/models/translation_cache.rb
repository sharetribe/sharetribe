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
      @model.send(@translation_attr_sym)
    end
  end

  def cache_key
    "/#{@model.class.name}/#{@model.id}/#{@translation_attr_sym.to_s}/#{@model.updated_at}"
  end

end
