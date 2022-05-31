module API
  module V1
    class Transactions < Grape::API
      include API::V1::Defaults     

      resource :transactions do

        desc "Create a Transaction"
        params do
           requires :transaction, :type => Hash do
            #optional :community_id, type: String
            #optional :community_uuid, type: String
            optional :listing_id, type: String
            #optional :listing_uuid, type: String
            #optional :listing_title, type: String
            optional :starter_id, type: String
            #optional :starter_uuid, type: String
            #optional :listing_author_id, type: String
            #optional :listing_author_uuid, type: String
            optional :listing_quantity, type: Integer
            #optional :unit_type, type: String
            #optional :unit_price, type: Integer
            #optional :unit_tr_key, type: String
            #optional :unit_selector_tr_key, type: String
            #optional :availability, type: String
            # optional :content, type: String
            # optional :payment_gateway, type: String
            # optional :payment_process, type: String
            # optional :booking_fields, type: String
            # optional :delivery_method, type: String
            # requires :payment_type, type: String
            # optional :booking_fields, type: Hash do
            #  optional :start_on, type: String
            #  optional :end_on, type: String
            #  optional :start_time, type: String
            #  optional :end_time, type: String
            #  optional :per_hour, type: Integer
            # end
           end
        end
        post "/new" do
          authenticate!

          payment_type = params[:transaction][:payment_type].to_sym
           case payment_type
           when :paypal
             # PayPal doesn't like images with cache buster in the URL
             logo_url = Maybe(opts[:community])
                      .wide_logo
                      .select { |wl| wl.present? }
                      .url(:paypal, timestamp: false)
                      .or_else(nil)

             gateway_fields =
               {
                 merchant_brand_logo_url: logo_url,
                 success_url: success_paypal_service_checkout_orders_url,
                 cancel_url: cancel_paypal_service_checkout_orders_url(listing_id: opts[:listing].id)
               }
           when :stripe
             gateway_fields =
               {
                 stripe_email: @current_user.primary_email.address,
                 stripe_token: params[:stripe_token],
                 shipping_address: params[:shipping_address],
                 service_name: "My Marketplace Name",
                 stripe_payment_method_id: params[:transaction][:payment][:stripe_payment_method_id]
               }
          end
          listing_author_id = Listing.find(params[:transaction][:listing_id]).author_id
          transaction = {
                community_id: 1,
                community_uuid: Community.find('1').uuid,
                listing_id: params[:transaction][:listing_id],
                listing_uuid: Listing.find(params[:transaction][:listing_id]).uuid,
                listing_title: Listing.find(params[:transaction][:listing_id]).title,
                starter_id: params[:transaction][:starter_id],
                starter_uuid: Person.find(params[:transaction][:starter_id]).uuid,
                listing_author_id: listing_author_id,
                listing_author_uuid: Person.find(listing_author_id).uuid,
                listing_quantity: params[:transaction][:listing_quantity],
                unit_type: Listing.find(params[:transaction][:listing_id]).unit_type,
                unit_price: Listing.find(params[:transaction][:listing_id]).price,
                unit_tr_key: Listing.find(params[:transaction][:listing_id]).unit_tr_key,
                unit_selector_tr_key: Listing.find(params[:transaction][:listing_id]).unit_selector_tr_key,
                availability: Listing.find(params[:transaction][:listing_id]).availability,
                content: params[:transaction][:content],
                payment_gateway: payment_type,
                payment_process: params[:transaction][:payment_process].to_sym || :preauthorize,
                booking_fields: params[:transaction][:booking_fields] || nil,
                delivery_method: params[:transaction][:delivery_method] || :none
          }
          transaction = TransactionService::Transaction.create({
           transaction: transaction,
           gateway_fields: gateway_fields
          }, force_sync: payment_type == :stripe)  
          
          puts transaction 
          if transaction.success
          present transaction[:data][:transaction][:id]
          else
            present transaction
          end
        end
        

        desc "Return Transaction"
        params do
          requires :transaction, :type => Hash do
            requires :id, :type => String
          end
        end
        post do
          authenticate!
          transaction = Transaction.find(params[:transaction][:id])
          present transaction
        end

        desc "Get All Transactions"
        params do
        end
        get do
          #authenticate!
          Transaction.all
        end







        desc "Update Booking"
        params do
          requires :transaction, type: Hash do
            requires :id, type: String
          end
        end
        put do
          authenticate!
          transaction = Transaction.find(params[:transaction][:id])
          personStarter = Transaction.find(params[:transaction][:id]).starter_id
          personListing = Transaction.find(params[:transaction][:id]).listing_author_id
          if @current_user == personStarter || @current_user == personListing
            person = Person.find(params[:person][:id])
            updatedTransaction.id = params[:transaction][:id] if params[:transaction][:id]
            updatedTransaction.starter_id = params[:transaction][:starter_id] if params[:transaction][:starter_id]
            updatedTransaction.listing_id = params[:transaction][:listing_id] if params[:transaction][:listing_id]
            updatedTransaction.conversation_id = params[:transaction][:conversation_id] if params[:transaction][:conversation_id]
            updatedTransaction.automatic_confirmation_after_days = params[:transaction][:automatic_confirmation_after_days] if params[:transaction][:automatic_confirmation_after_days]
            updatedTransaction.community_id = params[:transaction][:community_id] if params[:transaction][:community_id]
            updatedTransaction.created_at = params[:transaction][:created_at] if params[:transaction][:created_at]
            updatedTransaction.updated_at = params[:transaction][:updated_at] if params[:transaction][:updated_at]
            updatedTransaction.starter_skipped_feedback = params[:transaction][:starter_skipped_feedback] if params[:transaction][:starter_skipped_feedback]
            updatedTransaction.author_skipped_feedback = params[:transaction][:author_skipped_feedback] if params[:transaction][:author_skipped_feedback]
            updatedTransaction.last_transition_at = params[:transaction][:last_transition_at] if params[:transaction][:last_transition_at]
            updatedTransaction.current_state = params[:transaction][:current_state] if params[:transaction][:current_state]
            updatedTransaction.commission_from_seller = params[:transaction][:commission_from_seller] if params[:transaction][:commission_from_seller]
            updatedTransaction.minimum_commission_cents = params[:transaction][:minimum_commission_cents] if params[:transaction][:minimum_commission_cents]
            updatedTransaction.minimum_commission_currency = params[:transaction][:minimum_commission_currency] if params[:transaction][:minimum_commission_currency]
            updatedTransaction.payment_gateway = params[:transaction][:payment_gateway] if params[:transaction][:payment_gateway]
            updatedTransaction.listing_quantity = params[:transaction][:listing_quantity] if params[:transaction][:listing_quantity]
            updatedTransaction.listing_author_id = params[:transaction][:listing_author_id] if params[:transaction][:listing_author_id]
            updatedTransaction.listing_title = params[:transaction][:listing_title] if params[:transaction][:listing_title]
            updatedTransaction.unit_type = params[:transaction][:unit_type] if params[:transaction][:unit_type]
            updatedTransaction.unit_price_cents = params[:transaction][:unit_price_cents] if params[:transaction][:unit_price_cents]
            updatedTransaction.unit_price_currency = params[:transaction][:unit_price_currency] if params[:transaction][:unit_price_currency]
            updatedTransaction.unit_tr_key = params[:transaction][:unit_tr_key] if params[:transaction][:unit_tr_key]
            updatedTransaction.unit_selector_tr_key = params[:transaction][:unit_selector_tr_key] if params[:transaction][:unit_selector_tr_key]
            updatedTransaction.payment_process = params[:transaction][:payment_process] if params[:transaction][:payment_process]
            updatedTransaction.delivery_method = params[:transaction][:delivery_method] if params[:transaction][:delivery_method]
            updatedTransaction.shipping_price_cents = params[:transaction][:shipping_price_cents] if params[:transaction][:shipping_price_cents]
            updatedTransaction.availability = params[:transaction][:availability] if params[:transaction][:availability]
            updatedTransaction.deleted = params[:transaction][:deleted] if params[:transaction][:deleted]
            updatedTransaction.commission_from_buyer = params[:transaction][:commission_from_buyer] if params[:transaction][:commission_from_buyer]
            updatedTransaction.minimum_buyer_fee_cents = params[:transaction][:minimum_buyer_fee_cents] if params[:transaction][:minimum_buyer_fee_cents]
            updatedTransaction.minimum_buyer_fee_currency = params[:transaction][:minimum_buyer_fee_currency] if params[:transaction][:minimum_buyer_fee_currency]
            updatedTransaction.save!
            updatedTransaction.reload
            present updatedTransaction
          else
            error!('You must be logged in as a party in the transaction.', 401)
          end
        end








        desc 'Delete a Transaction (via "delete" field)'
        params do
          requires :id, type: String, desc: 'ID.'
        end
        delete do
          authenticate!
          transaction = Transaction.find(params[:transaction][:id])
          personStarter = Transaction.find(params[:transaction][:id]).starter_id
          personListing = Transaction.find(params[:transaction][:id]).listing_author_id
          if @current_user == personStarter || @current_user == personListing
            transaction.deleted = 1
            transaction.save!
            present transaction
          else
            error!('You must be logged in as a party in the transaction.', 401)
          end
          
        end








      end

    end
  end
end