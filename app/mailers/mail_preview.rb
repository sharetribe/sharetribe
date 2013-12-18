class MailPreview < MailView

  def new_payment
    recipient = Struct.new(:id, :given_name_or_username, :confirmed_notification_emails_to, :new_email_auth_token, :locale).new("123", "Test Recipient", "test@example.com", "123-abc", "en")
    payer = Struct.new(:id, :name, :given_name_or_username).new("123", "Test Payer", "Test Payer")
    listing = Struct.new(:title).new("Hammer")
    conversation = Struct.new(:id, :listing).new(123, listing)
    row_klass = Struct.new(:sum_cents, :sum, :sum_symbol, :vat, :sum_with_vat, :title)
    rows = [row_klass.new(5000, 50, "EUR", 23, 50 * 1.23, "Hammer")]
    payment = Struct.new(:recipient, :payer, :conversation, :sum_without_commission, :rows).new(recipient, payer, conversation, 5000, rows)
    community = Struct.new(:full_domain, :name, :full_name, :custom_email_from_address).new('http://marketplace.example.com', 'Example Marketplace', 'Example Marketplace', 'marketplace@example.com')
    
    PersonMailer.new_payment(payment, community)
  end

  def payment_settings_reminder
    recipient = Struct.new(:id, :given_name_or_username, :confirmed_notification_emails_to, :new_email_auth_token, :locale).new("123", "Test Recipient", "test@example.com", "123-abc", "en")
    listing = Struct.new(:id, :title).new(123, "Hammer")
    payment_gateway = Class.new()
    payment_gateway.define_singleton_method(:settings_url) { |*args| "http://marketplace.example.com/payment_settings_url" }
    community = Struct.new(:full_domain, :name, :full_name, :custom_email_from_address, :payment_gateway).new('http://marketplace.example.com', 'Example Marketplace', 'Example Marketplace', 'marketplace@example.com', payment_gateway)
    community.define_singleton_method(:payments_in_use?) { true }
    
    PersonMailer.payment_settings_reminder(listing, recipient, community)
  end

  def receipt_to_payer
    recipient = Struct.new(:id, :given_name_or_username).new("123", "Test Recipient")
    recipient.define_singleton_method(:name) { |*args| "Test Recipient" }
    payer = Struct.new(:id, :name, :given_name_or_username, :new_email_auth_token, :confirmed_notification_emails_to, :locale).new("123", "Test Payer", "Test Payer", "123-abc", "test@example.com", "en")
    listing = Struct.new(:title).new("Hammer")
    conversation = Struct.new(:id, :listing).new(123, listing)
    row_klass = Struct.new(:sum_cents, :sum, :sum_symbol, :vat, :sum_with_vat, :title)
    rows = [row_klass.new(5000, 50, "EUR", 23, 50 * 1.23, "Hammer")]
    community = Struct.new(:full_domain, :name, :full_name, :custom_email_from_address, :vat).new('http://marketplace.example.com', 'Example Marketplace', 'Example Marketplace', 'marketplace@example.com', 12)
    payment = Struct.new(:recipient, :payer, :conversation, :community, :sum_without_commission, :commission_without_vat, :rows, :total_sum, :total_commission).new(recipient, payer, conversation, community, 5000, 10, rows, 5000, 12)

    PersonMailer.receipt_to_payer(payment, community)
  end

  def braintree_receipt_to_payer
    recipient = Struct.new(:id, :given_name_or_username).new("123", "Test Recipient")
    recipient.define_singleton_method(:name) { |*args| "Test Recipient" }
    payer = Struct.new(:id, :name, :given_name_or_username, :new_email_auth_token, :confirmed_notification_emails_to, :locale).new("123", "Test Payer", "Test Payer", "123-abc", "test@example.com", "en")
    listing = Struct.new(:title).new("Hammer")
    conversation = Struct.new(:id, :listing).new(123, listing)
    community = Struct.new(:full_domain, :name, :full_name, :custom_email_from_address, :vat).new('http://marketplace.example.com', 'Example Marketplace', 'Example Marketplace', 'marketplace@example.com', 12)
    payment = Struct.new(:recipient, :payer, :conversation, :community, :sum_without_commission, :commission_without_vat, :total_sum, :total_commission, :currency).new(recipient, payer, conversation, community, 5000, 10, 5000, 12, "EUR")

    PersonMailer.braintree_receipt_to_payer(payment, community)
  end

  def braintree_new_payment
    recipient = Struct.new(:id, :given_name_or_username, :confirmed_notification_emails_to, :new_email_auth_token, :locale).new("123", "Test Recipient", "test@example.com", "123-abc", "en")
    payer = Struct.new(:id, :name, :given_name_or_username).new("123", "Test Payer", "Test Payer")
    listing = Struct.new(:title).new("Hammer")
    conversation = Struct.new(:id, :listing).new(123, listing)
    community = Struct.new(:full_domain, :name, :full_name, :custom_email_from_address, :commission_from_seller).new('http://marketplace.example.com', 'Example Marketplace', 'Example Marketplace', 'marketplace@example.com', 12)
    payment = Struct.new(:recipient, :payer, :conversation, :community, :commission_without_vat, :total_sum, :sum_cents, :currency)
                    .new(recipient,   payer,  conversation,  community,                    5000,       5000,     500000,     "EUR")
    
    PersonMailer.braintree_new_payment(payment, community)
  end
end