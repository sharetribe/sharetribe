module MarketplaceService
  module Listing
    ListingModel = ::Listing

    module Entity
      Listing = EntityUtils.define_builder(
        [:id, :mandatory, :fixnum],
        [:title, :mandatory, :string],
        [:author_id, :mandatory, :string],
        [:price, :optional, :money],
        [:quantity, :optional, :string],
        [:transaction_type_id, :mandatory, :fixnum])

      TransactionType = EntityUtils.define_builder(
        [:id, :mandatory, :fixnum],
        [:type, :mandatory, :string],
        [:price_per, :optional, :string],
        [:price_field, :optional, :to_bool],
        [:preauthorize_payment, :optional, :to_bool],
        [:url, :optional, :to_bool],
        [:action_button_label_translations, :optional])

      module_function

      def transaction_direction(transaction_type)
        direction_map = {
          ["Give", "Lend", "Rent", "Sell", "Service", "ShareForFree", "Swap", "Offer"] => "offer",
          ["Request"] => "request",
          ["Inquiry"] => "inquiry"
        }

        _, direction = direction_map.find { |(transaction_types, direction)| transaction_types.include? transaction_type }

        if direction.nil?
          raise("Unknown listing type: #{transaction_type}")
        else
          direction
        end
      end

      def discussion_type(transaction_type)
        case transaction_direction(transaction_type)
        when "request"
          "offer"
        when "offer"
          "request"
        else
          raise("No discussion type for transaction type: #{transaction_type}")
        end
      end

      def listing(listing_model)
        Listing.call(EntityUtils.model_to_hash(listing_model).merge(price: listing_model.price))
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

        payment_type &&
        listing.transaction_type.is_offer? &&
        !TransactionService::Transaction.can_start_transaction(query_info).data[:result]
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

    end
  end
end
