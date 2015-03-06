module TranslationService::API

  class Translations

    TranslationStore = TranslationService::Store::Translation


    ## GET /translations/:community_id/
    def get(community_id, request_params = {})
      begin
        params = TranslationService::DataTypes::Translation
          .validate_find_params(request_params)

        Result::Success.new(TranslationStore.get({
                              community_id: community_id
                              }.merge(params)))
      rescue ArgumentError => error
        Result::Error.new(error.message)
      end
    end


    # POST /translations/:community_id/
    def create(community_id, translation_groups = [])
      if translation_groups.empty?
        msg = "You must specify 'translation_groups' as an array of hash-objects containing translation_key and array of translations - like: [ { translation_key: nil, translations: [ { locale: 'en-US' , translation: 'Hi!'}, { locale: 'fi-FI', translation: 'Moi!'}]}]"
        return Result::Error.new(msg)
      end

      begin
        groups = TranslationService::DataTypes::Translation
          .validate_translation_groups({translation_groups: translation_groups})

        Result::Success.new(TranslationStore.create({
                              community_id: community_id,
                              translation_groups: groups[:translation_groups]
                            }))
      rescue Exception => error
        msg = "Translation_groups data structure is not valid"
        Result::Error.new(msg)
      end

    end

    # PUT /translations/:community_id/
    def update(community_id, translation_groups = [])
      raise NoMethodError.new("Not implemented")
    end

    # DELETE /translations/:community_id/
    def delete(community_id, translation_keys = [])
      begin
        params = TranslationService::DataTypes::Translation
          .validate_delete_params(translation_keys: translation_keys)

        Result::Success.new(TranslationStore.delete({
                              community_id: community_id
                              }.merge(params)))
      rescue ArgumentError => error
        Result::Error.new(error.message)
      end

    end

  end
end