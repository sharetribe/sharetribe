module MarketplaceService
  module Listing
    ListingModel = ::Listing

    module Entity
      Listing = EntityUtils.define_builder(
        [:id, :mandatory, :fixnum],
        [:title, :mandatory, :string],
        [:author_id, :mandatory, :string],
        [:price, :optional, :money],
        [:require_shipping_address, :optional, :to_bool],
        [:pickup_enabled, :optional, :to_bool],
        [:shipping_price, :optional, :money],
        [:quantity, :optional, :string],
        [:transaction_type_id, :mandatory, :fixnum],
        [:deleted, :to_bool]
      )

      TransactionType = EntityUtils.define_builder(
        [:id, :mandatory, :fixnum],
        [:type, :mandatory, :string],
        [:price_per, :optional, :string],
        [:price_field, :optional, :to_bool],
        [:preauthorize_payment, :optional, :to_bool],
        [:url, :optional, :to_bool],
        [:action_button_label_translations, :optional])

      module_function

      def listing(listing_model)
        Listing.call(EntityUtils.model_to_hash(listing_model).merge({price: listing_model.price, shipping_price: listing_model.shipping_price}))
      end

      def transaction_type(transaction_type_model)
        translations = transaction_type_model.translations
          .map { |translation|
            {
              locale: translation.locale,
              action_button_label: translation.action_button_label
            }
          }

        TransactionType.call(EntityUtils
          .model_to_hash(transaction_type_model)
          .merge(action_button_label_translations: translations)
        )
      end

      def send_payment_settings_reminder?(listing_id, community_id)
        listing = ListingModel.find(listing_id)
        payment_type = MarketplaceService::Community::Query.payment_type(community_id)

        query_info = {
          transaction: {
            payment_gateway: payment_type,
            listing_author_id: listing.author.id,
            community_id: community_id
          }
        }

        process = TransactionService::API::Api.processes.get(
          community_id: community_id,
          process_id: listing.transaction_type.transaction_process_id
        ).data[:process].to_sym

        payment_type &&
        (process == :preauthorize || process == :postpay) &&
        !TransactionService::Transaction.can_start_transaction(query_info).data[:result]
      end
    end

    module Command
      module_function

      #
      # DELETE /listings/:author_id
      def delete_listings(author_id)
        listings = ListingModel.where(author_id: author_id)
        listings.update_all(
          # Delete listing info
          description: nil,
          origin: nil,
          open: false,

          deleted: true
        )

        ids = listings.pluck(:id)
        ListingImage.where(listing_id: ids).destroy_all

        Result::Success.new
      end
    end

    module Query

      module_function

      def listing(listing_id)
        listing_model = ListingModel.find(listing_id)
        MarketplaceService::Listing::Entity.listing(listing_model)
      end

      def listing_with_transaction_type(listing_id)
        listing_model = ListingModel.find(listing_id)
        listing = MarketplaceService::Listing::Entity.listing(listing_model)
        listing.delete(:transaction_type_id)
        listing.merge(transaction_type: MarketplaceService::Listing::Entity.transaction_type(listing_model.transaction_type))
      end

      def open_listings_with_price_for(community_id, person_id)
        ListingModel
          .includes(:communities)
          .includes(:transaction_type)
          .where(
            {
              communities: { id: community_id },
              transaction_types: { price_field: true },
              author_id: person_id,
              open: true
            })
          .map { |l| MarketplaceService::Listing::Entity.listing(l) }
      end
    end
  end
end
