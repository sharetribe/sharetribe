module Form
  NewMarketplace = FormUtils.define_form("NewMarketplaceForm",
    :admin_email, :admin_first_name, :admin_last_name, :admin_password,
    :marketplace_country, :marketplace_language, :marketplace_name, :marketplace_type
  ).with_validations do
    validates_presence_of :admin_email, :admin_first_name, :admin_last_name, :admin_password
    validates_format_of   :admin_email, with: /\A[A-Z0-9._%\-\+\~\/]+@([A-Z0-9-]+\.)+[A-Z]+\z/i
    validates_length_of   :admin_password, minimum: 8
    validates_length_of   :admin_first_name, in: 1..255
    validates_length_of   :admin_last_name, in: 1..255
    validates_presence_of :marketplace_country, :marketplace_language, :marketplace_name, :marketplace_type
    validates             :marketplace_type, inclusion: { in: %w(product rental service) }
    validates_length_of   :marketplace_country, is: 2
    validates_length_of   :marketplace_language, minimum: 2
  end

end
