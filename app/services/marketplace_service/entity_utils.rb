module MarketplaceService
  module EntityUtils
    module_function

    # Define an entity constructor Proc, which returns a Hash
    #
    # Usage:
    #
    # -- in some service / Entity --
    #
    # Person = MarketplaceService::EntityUtils.define_entity(
    #   :username,
    #   :password)
    #
    # -- in some service / Query --
    #
    # def person(person_id)
    #   Maybe(Person.where(person_id: person_id.first)
    #     .map { |model| Person.call(model) }
    #     .or_else(nil)
    # end
    #
    def define_entity(*ks)
      -> (opts = {}) {

        ks.inject({}) do |memo, k|
          memo[k.to_sym] = opts[k] unless opts[k].nil?
          memo
        end
      }
    end

    # Ensure first level keys are all symbols, not strings
    def hash_keys_to_symbols(hash)
      Hash[hash.map { |(k, v)| [k.to_sym, v] }]
    end

    # Turn active record model into a hash with string keys replaced with symbols
    def model_to_hash(model)
      return {} if model.nil?
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
