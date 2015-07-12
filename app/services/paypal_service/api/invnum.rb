#helper methods to help handle invoice numbers

module PaypalService::API::Invnum

  VALID_TYPES = [:payment, :commission]

  module_function

  def create(community_id, transaction_id, type)
    raise ArgumentError.new("Illegal type: #{type} for invoice number.") unless VALID_TYPES.include? type
    "#{community_id}-#{transaction_id}-#{type}"
  end

  def type(number)
    number.split('-').last.to_sym
  end

  def community_id(number)
    number.split('-').first
  end

  def transaction_id(number)
    number.split('-')[1]
  end
end
