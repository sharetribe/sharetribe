#
# Helper module to create transaction types. Can be used from the application code (super admin controller) or from
# console
#
# Console usage:
#
# c = Community.find(1234)
# TransactionTyperCreator.create(c, "Sell")
#
module TransactionTypeCreator

  TRANSACTION_TYPES = {
    "Give" => {
      label: "Give",
      translation_key: "admin.transaction_types.give",
      action_button_translation_key: "admin.transaction_types.default_action_button_labels.offer",
      defaults: Give::DEFAULTS
    },
    "Inquiry" => {
      label: "Inquiry",
      translation_key: "admin.transaction_types.inquiry",
      action_button_translation_key: "admin.transaction_types.default_action_button_labels.inquiry",
      defaults: Inquiry::DEFAULTS
    },
    "Lend" => {
      label: "Lend",
      translation_key: "admin.transaction_types.lend",
      action_button_translation_key: "admin.transaction_types.default_action_button_labels.offer",
      defaults: Lend::DEFAULTS
    },
    "Rent" => {
      label: "Rent",
      translation_key: "admin.transaction_types.rent",
      action_button_translation_key: "admin.transaction_types.default_action_button_labels.rent",
      defaults: Rent::DEFAULTS
    },
    "Request" => {
      label: "Request",
      translation_key: "admin.transaction_types.request",
      action_button_translation_key: "admin.transaction_types.default_action_button_labels.request",
      defaults: Request::DEFAULTS
    },
    "Sell" => {
      label: "Sell",
      translation_key: "admin.transaction_types.sell",
      action_button_translation_key: "admin.transaction_types.default_action_button_labels.sell",
      defaults: Sell::DEFAULTS
    },
    "Service" => {
      label: "Service",
      translation_key: "admin.transaction_types.service",
      action_button_translation_key: "admin.transaction_types.default_action_button_labels.offer",
      defaults: Service::DEFAULTS
    },
    "ShareForFree" => {
      label: "Share for free",
      translation_key: "admin.transaction_types.share_for_free",
      action_button_translation_key: "admin.transaction_types.default_action_button_labels.offer",
      defaults: ShareForFree::DEFAULTS
    },
    "Swap" => {
      label: "Swap",
      translation_key: "admin.transaction_types.swap",
      action_button_translation_key: "admin.transaction_types.default_action_button_labels.offer",
      defaults: Swap::DEFAULTS
    }
  }

  module_function

  def create(community, transaction_type_class_name)
    throw "Transaction type #{transaction_type_class_name} not available. Available types are: #{available_types.join(', ')}" unless available_types.include? transaction_type_class_name

    transaction_type_description = TRANSACTION_TYPES[transaction_type_class_name]
    defaults = transaction_type_description[:defaults] || {}

    # Create
    transaction_type = community.transaction_types.build(
      {type: transaction_type_class_name}.merge(defaults)
    )

    # Locales
    community.locales.each do |locale|

      transaction_type.translations.build({
        locale: locale,
        name: I18n.t(transaction_type_description[:translation_key], :locale => locale.to_sym),
        action_button_label: I18n.t(transaction_type_description[:action_button_translation_key], :locale => locale.to_sym)
      })
    end

    #enable preauthorized payments
    transaction_type.preauthorize_payment = true

    transaction_type.save!

    # Categories
    community.categories.each do |category|
      use_in_category(category, transaction_type)
    end

    transaction_type
  end

  def available_types
    TransactionTypeCreator::TRANSACTION_TYPES.map { |type, settings| type }
  end

  def use_in_category(category, transaction_type)
    CategoryTransactionType.create(:category_id => category.id, :transaction_type_id => transaction_type.id)
  end

end
