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

      def listing(listing_model)
        Listing.call(EntityUtils.model_to_hash(listing_model).merge(price: listing_model.price))
      end
    end
  end
end
