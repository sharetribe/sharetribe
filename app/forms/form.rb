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

  class EmailAvailableValidator < ActiveModel::Validator
    def validate(form)
      options[:fields].each do |f|
        email_address = form.send(f)
        form.errors.add(f, "Email address #{email_address} is not available.") unless Email.email_available?(email_address)
      end
    end
  end

  NewMarketplace = FormUtils.define_form("NewMarketplaceForm",
    :admin_email, :admin_first_name, :admin_last_name, :admin_password,
    :marketplace_country, :marketplace_language, :marketplace_name, :marketplace_type
  ).with_validations do
    validates_presence_of :admin_email, :admin_first_name, :admin_last_name, :admin_password
    validates_format_of   :admin_email, with: /\A[A-Z0-9._%\-\+\~\/]+@([A-Z0-9-]+\.)+[A-Z]+\z/i
    validates_with        EmailAvailableValidator, fields: [:admin_email]
    validates_length_of   :admin_password, minimum: 8
    validates_length_of   :admin_first_name, in: 1..255
    validates_length_of   :admin_last_name, in: 1..255
    validates_presence_of :marketplace_country, :marketplace_language, :marketplace_name, :marketplace_type
    validates             :marketplace_type, inclusion: { in: %w(product rental service) }
    validates_length_of   :marketplace_country, is: 2
    validates_length_of   :marketplace_language, minimum: 2
  end

end
