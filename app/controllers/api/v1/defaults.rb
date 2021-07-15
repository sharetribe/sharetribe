module API
  module V1
    module Defaults
      extend ActiveSupport::Concern
      include ActionController::HttpAuthentication::Token

      included do
        prefix "api"
        version "v1", using: :path
        default_format :json
        format :json
        formatter :json, 
             Grape::Formatter::ActiveModelSerializers
        
        helpers do

          def tokenHeader
            arr = headers['Authorization'].split
            return arr[1]
          end


          def permitted_params
            @permitted_params ||= declared(params, 
               include_missing: false)
          end

          def logger
            Rails.logger
          end

         def authenticate!
           error!('Unauthorized. Invalid or expired token.', 401) unless current_user
         end

         def current_user
          return nil if headers['Authorization'].nil?
          token = ApiKey.where(access_token: tokenHeader).first
          # token = ApiKey.where(access_token: params[:token]).first
           if token && !token.expired?
             @current_user = Person.find(token.user_id)
           else
             false
           end
          end
        end

        rescue_from ActiveRecord::RecordNotFound do |e|
          error_response(message: e.message, status: 200)
        end

        rescue_from ActiveRecord::RecordInvalid do |e|
          error_response(message: e.message, status: 200)
        end

        # rescue_from ArgumentError do |e|
        #  error_response(message: e.message, status: 200)
        # end

        # rescue_from StandardError do |e|
        #  error_response(message: e, status: 200)
        # end



      end
    end
  end
end