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
        post do
          authenticate!
          booking = Bookings.new
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
          requires :person, type: Hash do
            requires :id, type: String
          end
        end
        put do
          authenticate!
          if @current_user == Person.find(params[:person][:id])
            person = Person.find(params[:person][:id])
            #person.community_id = params[:person][:community_id] if params[:person][:community_id]
            #person.updated_at = params[:person][:updated_at] if params[:person][:updated_at]
            #person.is_admin = params[:person][:is_admin] if params[:person][:is_admin]
            person.locale = params[:person][:locale] if params[:person][:locale]
            # person.preferences = params[:person][:preferences] if params[:person][:preferences]
            # person.active_days_count = params[:person][:active_days_count] if params[:person][:active_days_count]
            person.last_page_load_date = params[:person][:last_page_load_date] if params[:person][:last_page_load_date]
            person.test_group_number = params[:person][:test_group_number] if params[:person][:test_group_number]
            person.username = params[:person][:username] if params[:person][:username]
            person.email = params[:person][:email] if params[:person][:email]
            person.encrypted_password = params[:person][:encrypted_password] if params[:person][:encrypted_password]
            person.legacy_encrypted_password = params[:person][:legacy_encrypted_password] if params[:person][:legacy_encrypted_password] 
            person.reset_password_token = params[:person][:reset_password_token] if params[:person][:reset_password_token]
            person.reset_password_sent_at = params[:person][:resetpassword_sent_at] if params[:person][:resetpassword_sent_at]
            person.remember_created_at = params[:person][:remember_created_at] if params[:person][:remember_created_at]
            person.sign_in_count = params[:person][:sign_in_count] if params[:person][:sign_in_count]
            person.current_sign_in_at = params[:person][:current_sign_in_at] if params[:person][:current_sign_in_at]
            person.last_sign_in_at = params[:person][:last_sign_in_at] if params[:person][:last_sign_in_at]
            person.current_sign_in_ip = params[:person][:current_sign_in_ip] if params[:person][:current_sign_in_ip]
            person.last_sign_in_ip = params[:person][:last_sign_in_ip] if params[:person][:last_sign_in_ip]
            person.password_salt = params[:person][:password_salt] if params[:person][:password_salt]
            person.given_name = params[:person][:given_name] if params[:person][:given_name]
            person.family_name = params[:person][:family_name] if params[:person][:family_name]
            person.display_name = params[:person][:display_name] if params[:person][:display_name]
            person.phone_number = params[:person][:phone_number] if params[:person][:phone_number]
            person.description = params[:person][:description] if params[:person][:description]
            person.image_file_name = params[:person][:image_file_name] if params[:person][:image_file_name]
            person.image_content_type = params[:person][:image_content_type] if params[:person][:image_content_type]
            person.image_file_size = params[:person][:image_file_size] if params[:person][:image_file_size]
            person.image_updated_at = params[:person][:image_updated_at] if params[:person][:image_updated_at]
            person.image_processing = params[:person][:image_processing] if params[:person][:image_processing]
            person.facebook_id = params[:person][:facebook_id] if params[:person][:facebook_id]
            person.authentication_token = params[:person][:authentication_token] if params[:person][:authentication_token]
            person.community_updates_last_sent_at = params[:person][:community_updates_last_sent_at] if params[:person][:community_updates_last_sent_at] 
            person.min_days_between_community_updates = params[:person][:min_days_between_community_updates] if params[:person][:min_days_between_community_updates]
            #person.deleted = params[:deleted]
            #person.cloned_from = params[:cloned_from]
            #person.google_oauth2_id = params[:google_oauth2_id]
            #person.linkedin_id = params[:linkedin_id]
            person.save!
            person.reload
            present person
          else
            error!('You must be logged in as the user you wish to update.', 401)
          end
        end








        desc 'Delete a Booking (via "delete" field)'
        params do
          requires :id, type: String, desc: 'ID.'
        end
        delete do
          authenticate!
          if @current_user == Person.find(params[:id])
            person.deleted = 1
            person.save
            present person
          else
            error!('You must be logged in as the user you wish to delete.', 401)
          end
          
        end









      end

    end
  end
end