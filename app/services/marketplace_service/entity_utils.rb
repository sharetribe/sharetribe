module MarketplaceService
  module EntityUtils
    module_function

    # Ensure first level keys are all symbols, not strings
    def hash_keys_to_symbols(hash)
      Hash[hash.map { |(k, v)| [k.to_sym, v] }]
    end

    # Turn active record model into a hash with string keys replaced with symbols
    def model_attrs_to_hash(model)
      hash_keys_to_symbols(model.attributes)
    end

    # Usage:
    # Entities.from_hash(Entities.PaypalAccount, {email: "myname@email.com"})
    def from_hash(entity_class, data)
      entity = entity_class.new
      entity.members.each { |m| entity[m] = data[m] }
      entity
    end
  end
end
