module API
  module V1
    class Base < Grape::API
      mount API::V1::Auth
      mount API::V1::People
      mount API::V1::Listings
      mount API::V1::Bookings
      mount API::V1::Transactions
      mount API::V1::Emails
      mount API::V1::Feedback
    end
  end
end