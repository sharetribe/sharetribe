module API
  module V1
    class CustomFieldNames < Grape::API
      include API::V1::Defaults

      resource :CustomFieldName do



        desc "Return all Custom Field Names"
        get do
            #authenticate!
            # CustomField.al_names
            CustomFieldName.all
        end









      end

    end
  end
end 