module Form
  Message = FormUtils.define_form("Message",
    :content,
    :conversation_id, # TODO Remove this
    :sender_id, # TODO Remove this
  ).with_validations {
    validates_presence_of :content, :conversation_id, :sender_id
  }

  Braintree = FormUtils.define_form("Braintree",
    :cardholder_name,
    :credit_card_number,
    :cvv,
    :credit_card_expiration_month,
    :credit_card_expiration_year
  )

  NewMarketplace = FormUtils.define_form("NewMarketplaceForm",
    :marketplace_country, :marketplace_language, :marketplace_name, :marketplace_type
  ).with_validations do
    validates_presence_of :marketplace_country, :marketplace_language, :marketplace_name, :marketplace_type
    validates             :marketplace_type, inclusion: { in: %w(product rental service) }
    validates_length_of   :marketplace_country, is: 2
    validates_length_of   :marketplace_language, minimum: 2
  end

end
