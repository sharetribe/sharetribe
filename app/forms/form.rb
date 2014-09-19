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
end
