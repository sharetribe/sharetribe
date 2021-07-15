module API
  module V1
    class People < Grape::API
      include API::V1::Defaults

      resource :people do

        desc "Create a User / Person"
        params do
           requires :email, :type => String, :desc => "User email"
           requires :fname, :type => String, :desc => "First name"
           requires :lname, :type => String, :desc => "Last name"
           requires :password, :type => String, :desc => "User password"
        end
        post do
        user = UserService::API::Users.create_user({
          given_name: params[:fname],
          family_name: params[:lname],
          email: params[:email],
          password: params[:password],
          locale: "en"},
          1).data

          present user
        end
        
        desc "Return all users / people"
        get do
          authenticate!
          Person.all
        end



      end

    end
  end
end