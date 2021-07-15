module API
  module V1
    class Auth < Grape::API
      include API::V1::Defaults


      resource :auth do

        desc "Authenticate user and return user object, access token"
        params do
           requires :login, :type => String, :desc => "User username or email"
           requires :password, :type => String, :desc => "User password"
        end
        post do
           login = params[:login]
           password = params[:password]


           if login.nil? or password.nil?
             error!({:error_code => 404, :error_message => "Invalid email or password."}, 401)
             return
           end

           if params[:login].include?("@")
             email = params[:login]
             if Email.find_by(address: email.downcase).present?
              userId = Email.find_by(address: email.downcase).person_id
              person = Person.find(userId)
             else
              error!({:error_code => 404, :error_message => "Invalid email or password."}, 401)
             end
           else
             username = params[:login]
             if Person.find_by(username: username.downcase).present?
              person = Person.find_by(username: username.downcase)
             else
              error!({:error_code => 404, :error_message => "Invalid email or password."}, 401)
             end
           end

           if person.nil?
              error!({:error_code => 404, :error_message => "Invalid email or password."}, 401)
              return
           end

           if !person.valid_password?(password)
              error!({:error_code => 404, :error_message => "Invalid email or password."}, 401)
              return
           else
            currKey = ApiKey.find_by(user_id: person.id)            
            if !currKey.present?
             key = ApiKey.create(user_id: person.id)
             present key
            elsif currKey.expired?
             currKey.delete
             key = ApiKey.create(user_id: person.id)
             present key
            elsif !currKey.expired?
             present currKey
            end
           end
          end
      end
    end
  end
end