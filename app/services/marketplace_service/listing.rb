module MarketplaceService
  module Listing
    module Entity
      Listing = EntityUtils.define_builder(
        [:id, :mandatory, :fixnum],
        [:title, :mandatory, :string],
        [:author_id, :mandatory, :string],
        [:price, :optional, :money],
        [:quantity, :optional, :string],
        [:transaction_type_id, :mandatory, :fixnum])

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
    end
  end
end
