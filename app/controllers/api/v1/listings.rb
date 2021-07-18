module API
  module V1
    class Listings < Grape::API
      include API::V1::Defaults

      resource :listings do

        desc "Create a listing"
        params do
          requires :create_listing, type: Integer
          requires :listing, type: Hash do
            requires :title, type: String
            requires :author_id, type: String
            requires :category_id, type: Integer
            requires :listing_shape_id, type: Integer
            optional :description, type: String
            optional :price_cents, type: Integer
            # requires :times_viewed, type: Integer
            # requires :updates_email_at, type: DateTime
            # requires :state, type: String
            requires :open, type: Integer
            requires :privacy, type: String
            # requires :comments_count, type: Integer
          end
        end
        post '/create' do
          newListing = Listing.new
          newListing.community_id = 1;
          #newListing.id = params[:id] if id = params[:id]
          #newListing.created_at = params[:listing][:created_at] if params[:listing][:created_at]
          #newListing.updated_at = params[:listing][:updated_at] if params[:listing][:updated_at]
          newListing.author_id = params[:listing][:author_id] if params[:listing][:author_id]
          newListing.title = params[:listing][:title] if params[:listing][:title]
          newListing.category = params[:listing][:category] if params[:listing][:category]
          newListing.category_id = params[:listing][:category_id] if params[:listing][:category_id]
          newListing.category_old = params[:listing][:category_old] if params[:listing][:category_old]
          newListing.times_viewed = params[:listing][:times_viewed] if params[:listing][:times_viewed]
          newListing.sort_date = params[:listing][:sort_date] if params[:listing][:sort_date]
          newListing.listing_type_old = params[:listing][:listing_type_old] if params[:listing][:listing_type_old]
          newListing.description = params[:listing][:description] if params[:listing][:description]
          newListing.origin = params[:listing][:origin] if params[:listing][:origin]
          newListing.destination = params[:listing][:destination] if params[:listing][:destination]
          newListing.valid_until = params[:listing][:valid_until] if params[:listing][:valid_until]
          newListing.delta = params[:listing][:delta] if params[:listing][:delta]
          newListing.open = params[:listing][:open] if params[:listing][:open]
          newListing.share_type_old = params[:listing][:share_type_old] if params[:listing][:share_type_old]
          newListing.privacy = params[:listing][:privacy] if params[:listing][:privacy]
          newListing.comments_count = params[:listing][:comments_count] if params[:listing][:comments_count]
          newListing.subcategory_old = params[:listing][:subcategory_old] if params[:listing][:subcategory_old]
          newListing.old_category_id = params[:listing][:old_category_id] if params[:listing][:old_category_id]
          newListing.share_type_id = params[:listing][:share_type_id] if params[:listing][:share_type_id]
          newListing.listing_shape_id = params[:listing][:listing_shape_id] if params[:listing][:listing_shape_id]
          newListing.transaction_process_id = params[:listing][:transaction_process_id] if params[:listing][:transaction_process_id]
          newListing.shape_name_tr_key = params[:listing][:shape_name_tr_key] if params[:listing][:shape_name_tr_key]
          newListing.action_button_tr_key = params[:listing][:action_button_tr_key] if params[:listing][:action_button_tr_key]
          newListing.price_cents = params[:listing][:price_cents] if params[:listing][:price_cents]
          newListing.currency = params[:listing][:currency] if params[:listing][:currency]
          newListing.quantity = params[:listing][:quantity] if params[:listing][:quantity]
          newListing.unit_type = params[:listing][:unit_type] if params[:listing][:unit_type]
          newListing.quantity_selector = params[:listing][:quantity_selector] if params[:listing][:quantity_selector]
          newListing.unit_tr_key = params[:listing][:unit_tr_key] if params[:listing][:unit_tr_key]
          newListing.deleted = params[:listing][:deleted] if params[:listing][:deleted]
          newListing.require_shipping_address = params[:listing][:require_shipping_address] if params[:listing][:require_shipping_address]
          newListing.pickup_enabled = params[:listing][:pickup_enabled] if params[:listing][:pickup_enabled]
          newListing.shipping_price_cents = params[:listing][:shipping_price_cents] if params[:listing][:shipping_price_cents]
          newListing.shipping_price_additional_cents = params[:listing][:shipping_price_additional_cents] if params[:listing][:shipping_price_additional_cents]
          newListing.availability = params[:listing][:availability] if params[:listing][:availability]
          newListing.per_hour_ready = params[:listing][:per_hour_ready] if params[:listing][:per_hour_ready]
          newListing.state = params[:listing][:state] if params[:listing][:state]
          newListing.approval_count = params[:listing][:approval_count] if params[:listing][:approval_count]
          newListing.save
          present newListing
        end
        



        desc "Read all listings"
        get do
            authenticate!
            Listing.all
        end

        desc "Search listings"
        params do
          requires :search, type: Hash
          requires :includes, type: String
        end
        post '/search' do
          authenticate!
          @view_type = params[:includes]
          includes =
          case @view_type
            when "grid"
              [:author, :listing_images]
            when "list"
              [:author, :listing_images, :num_of_reviews]
            when "map"
              [:location]
            else
              raise ArgumentError.new("Unknown view_type #{@view_type}")
          end
          result = ListingIndexService::API::Api.listings.search(
            community_id: 1,
            search: params[:search],
            includes: includes,
            engine: FeatureFlagHelper.search_engine
            )
          present result
        end


        desc "Update listing"
        params do
          requires :listing, type: Hash do
            requires :id, type: String
          end
        end
        put do
          authenticate!
          listing = Listing.find(params[:listing][:id])
          person = Person.find(listing.author_id)
          if @current_user == person
            updatedListing = listing
            updatedListing.community_id = 1;
            #updatedListing.id = params[:id] if id = params[:id]
            updatedListing.created_at = params[:listing][:created_at] if params[:listing][:created_at]
            updatedListing.updated_at = params[:listing][:updated_at] if params[:listing][:updated_at]
            updatedListing.author_id = params[:listing][:author_id] if params[:listing][:author_id]
            updatedListing.title = params[:listing][:title] if params[:listing][:title]
            updatedListing.category = params[:listing][:category] if params[:listing][:category]
            updatedListing.category_id = params[:listing][:category_id] if params[:listing][:category_id]
            updatedListing.category_old = params[:listing][:category_old] if params[:listing][:category_old]
            updatedListing.times_viewed = params[:listing][:times_viewed] if params[:listing][:times_viewed]
            updatedListing.sort_date = params[:listing][:sort_date] if params[:listing][:sort_date]
            updatedListing.listing_type_old = params[:listing][:listing_type_old] if params[:listing][:listing_type_old]
            updatedListing.description = params[:listing][:description] if params[:listing][:description]
            updatedListing.origin = params[:listing][:origin] if params[:listing][:origin]
            updatedListing.destination = params[:listing][:destination] if params[:listing][:destination]
            updatedListing.valid_until = params[:listing][:valid_until] if params[:listing][:valid_until]
            updatedListing.delta = params[:listing][:delta] if params[:listing][:delta]
            updatedListing.open = params[:listing][:open] if params[:listing][:open]
            updatedListing.share_type_old = params[:listing][:share_type_old] if params[:listing][:share_type_old]
            updatedListing.privacy = params[:listing][:privacy] if params[:listing][:privacy]
            updatedListing.comments_count = params[:listing][:comments_count] if params[:listing][:comments_count]
            updatedListing.subcategory_old = params[:listing][:subcategory_old] if params[:listing][:subcategory_old]
            updatedListing.old_category_id = params[:listing][:old_category_id] if params[:listing][:old_category_id]
            updatedListing.share_type_id = params[:listing][:share_type_id] if params[:listing][:share_type_id]
            updatedListing.listing_shape_id = params[:listing][:listing_shape_id] if params[:listing][:listing_shape_id]
            updatedListing.transaction_process_id = params[:listing][:transaction_process_id] if params[:listing][:transaction_process_id]
            updatedListing.shape_name_tr_key = params[:listing][:shape_name_tr_key] if params[:listing][:shape_name_tr_key]
            updatedListing.action_button_tr_key = params[:listing][:action_button_tr_key] if params[:listing][:action_button_tr_key]
            updatedListing.price_cents = params[:listing][:price_cents] if params[:listing][:price_cents]
            updatedListing.currency = params[:listing][:currency] if params[:listing][:currency]
            updatedListing.quantity = params[:listing][:quantity] if params[:listing][:quantity]
            updatedListing.unit_type = params[:listing][:unit_type] if params[:listing][:unit_type]
            updatedListing.quantity_selector = params[:listing][:quantity_selector] if params[:listing][:quantity_selector]
            updatedListing.unit_tr_key = params[:listing][:unit_tr_key] if params[:listing][:unit_tr_key]
            #updatedListing.deleted = params[:listing][:deleted] if params[:listing][:deleted]
            updatedListing.require_shipping_address = params[:listing][:require_shipping_address] if params[:listing][:require_shipping_address]
            updatedListing.pickup_enabled = params[:listing][:pickup_enabled] if params[:listing][:pickup_enabled]
            updatedListing.shipping_price_cents = params[:listing][:shipping_price_cents] if params[:listing][:shipping_price_cents]
            updatedListing.shipping_price_additional_cents = params[:listing][:shipping_price_additional_cents] if params[:listing][:shipping_price_additional_cents]
            updatedListing.availability = params[:listing][:availability] if params[:listing][:availability]
            updatedListing.per_hour_ready = params[:listing][:per_hour_ready] if params[:listing][:per_hour_ready]
            updatedListing.state = params[:listing][:state] if params[:listing][:state]
            updatedListing.approval_count = params[:listing][:approval_count] if params[:listing][:approval_count]
            updatedListing.save!
            present updatedListing
          else
            error!('You must be logged in as the user who made this listing in order to update it.', 401)
          end
        end


        desc "Delete a Listing"
        params do
          requires :listing, type: Hash do
            requires :id, type: String
          end
        end
        delete do
          authenticate!
          listing = Listing.find(params[:listing][:id])
          person = Person.find(listing.author_id)
          if @current_user == person
            listing.update_attribute(:deleted, 1)
            present listing
          else
            error!('You must be logged in as the user who made this listing in order to delete it.', 401)
          end
        end






      end

    end
  end
end