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

      ks.reduce({}) do |memo, k|
        memo[k.to_sym] = opts[k]
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

  # rename keys in given hash (returns a copy) using the renames old_key => new_key mappings
  def rename_keys(renames, hash)
    renames.reduce(hash.dup) do |h, (old_key, new_key)|
      h[new_key] = h[old_key] if h.has_key?(old_key)
      h.delete(old_key)
      h
    end
  end

end
