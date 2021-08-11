module API
  module V1
    class Base < Grape::API

      use Grape::Middleware::Globals

      require 'grape-active_model_serializers'
      include Grape::ActiveModelSerializers 


      mount API::V1::Auth
      mount API::V1::People
      mount API::V1::Listings
      mount API::V1::Bookings
      mount API::V1::Transactions
      #mount API::V1::Emails
      #mount API::V1::Feedback
      mount API::V1::Categories
      mount API::V1::CustomFields
      mount API::V1::CustomFieldNames
    end
  end
end