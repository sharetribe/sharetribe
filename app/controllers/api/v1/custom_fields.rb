module API
  module V1
    class CustomFields < Grape::API
      include API::V1::Defaults


      resource ':custom_fields' do



        desc "Return all Custom Fields"
        get '/' do
            #authenticate!
            #
            # @fields = CustomField.all
            # render json: @fields, includes: '**'
            #present CustomField.includes(:names).as_json()
            # CustomFieldName.
            present CustomField.all
        end








      end

    end
  end
end