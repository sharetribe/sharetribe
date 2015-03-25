module TranslationService::API

  class Translations

    def initialize
      @store = TranslationService::Store::Translation::CachedTranslationStore.new
    end


    ## GET /translations/:community_id/
    def get(community_id, request_params = {})
      params = TranslationService::DataTypes::Translation
        .validate_find_params(request_params)

      Result::Success.new(@store.get({
                            community_id: community_id
                            }.merge(params)))
    end


    # POST /translations/:community_id/
    def create(community_id, translation_groups = [])
      if translation_groups.empty?
        msg = "You must specify 'translation_groups' as an array of hash-objects containing translation_key and array of translations - like: [ { translation_key: nil, translations: [ { locale: 'en-US' , translation: 'Hi!'}, { locale: 'fi-FI', translation: 'Moi!'}]}]"
        raise ArgumentError.new(msg)
      end

      groups = TranslationService::DataTypes::Translation
        .validate_translation_groups({translation_groups: translation_groups})

      Result::Success.new(@store.create({
                            community_id: community_id,
                            translation_groups: groups[:translation_groups]
                          }))

    end


    # DELETE /translations/:community_id/
    def delete(community_id, translation_keys = [])
      if translation_keys.empty?
        msg = "You must specify an array of translation_key objects. e.g. '[{translation_key: \"dfnv7858vfjgk\"}, {translation_key: \"dfnv7858vfjgk\"}]"
        raise ArgumentError.new(msg)
      end


      params = TranslationService::DataTypes::Translation
        .validate_delete_params(translation_keys: translation_keys)

      Result::Success.new(@store.delete({
                            community_id: community_id
                            }.merge(params)))

    end

  end
end