module API
  module V1
    class Bookings < Grape::API
      include API::V1::Defaults

      resource :bookings do

        desc "Create a Booking"
        params do
           requires :booking, :type => Hash do
           end
        end
        post "/create" do
          authenticate!
          booking = Booking.new
          booking.start_on = params[:booking][:start_on] if params[:booking][:start_on]
          booking.end_on = params[:booking][:end_on] if params[:booking][:end_on]
          start_time = params[:booking][:start_time] if params[:booking][:start_time]
          booking.start_time = start_time.to_datetime
          booking.end_time = params[:booking][:end_time] if params[:booking][:end_time]
          booking.per_hour = params[:booking][:per_hour] if params[:booking][:per_hour]
          booking.transaction_id = params[:booking][:transaction_id] if params[:booking][:transaction_id]
          booking.save!
          present booking
        end
        


        desc "Return Booking"
        params do
          requires :booking, :type => Hash do
            requires :id, :type => String
          end
        end
        post do
          authenticate!
          booking = Bookings.find(params[:booking][:id])
          present booking
        end








        desc "Update Booking"
        params do
          requires :booking, type: Hash do
            requires :id, type: String
          end
        end
        put do
          authenticate!
          updatedBooking.id = params[:booking][:id] if params[:booking][:id]
          updatedBooking.transaction_id = params[:booking][:transaction_id] if params[:booking][:transaction_id]
          updatedBooking.start_on = params[:booking][:start_on] if params[:booking][:start_on]
          updatedBooking.end_on = params[:booking][:end_on] if params[:booking][:end_on]
          updatedBooking.created_at = params[:booking][:created_at] if params[:booking][:created_at]
          updatedBooking.updated_at = params[:booking][:updated_at] if params[:booking][:updated_at]
          updatedBooking.start_time = params[:booking][:start_time] if params[:booking][:start_time]
          updatedBooking.end_time = params[:booking][:end_time] if params[:booking][:end_time]
          updatedBooking.per_hour = params[:booking][:per_hour] if params[:booking][:per_hour]
          updatedBooking.save!
          updatedBooking.reload
          present updatedBooking
        end








        desc 'Delete a Booking'
        params do
          requires :booking, type: Hash do
            requires :id, type: String
        end
        delete do
          authenticate!
          booking = Booking.find(params[:booking][:id])
          booking.destory
          present "Success. Deleted booking."
          
        end









      end

    end
  end
end