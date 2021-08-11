module API
  module V1
    class Categories < Grape::API
      include API::V1::Defaults

      resource :categories do



        desc "Return all Categories"
        get do
          #authenticate!
          Category.all
        end









      end

    end
  end
end