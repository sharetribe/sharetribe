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
      action_button_translation_key: "admin.transaction_types.default_action_button_labels.offer"
    },
    "Inquiry" => {
      label: "Inquiry",
      translation_key: "admin.transaction_types.inquiry",
      action_button_translation_key: "admin.transaction_types.default_action_button_labels.inquiry"
    },
    "Lend" => {
      label: "Lend",
      translation_key: "admin.transaction_types.lend",
      action_button_translation_key: "admin.transaction_types.default_action_button_labels.offer"
    },
    "Rent" => {
      label: "Rent",
      translation_key: "admin.transaction_types.rent",
      action_button_translation_key: "admin.transaction_types.default_action_button_labels.rent"
    },
    "Request" => {
      label: "Request",
      translation_key: "admin.transaction_types.request",
      action_button_translation_key: "admin.transaction_types.default_action_button_labels.request"
    },
    "Sell" => {
      label: "Sell",
      translation_key: "admin.transaction_types.sell",
      action_button_translation_key: "admin.transaction_types.default_action_button_labels.sell"
    },
    "Service" => {
      label: "Service",
      translation_key: "admin.transaction_types.service",
      action_button_translation_key: "admin.transaction_types.default_action_button_labels.offer"
    },
    "ShareForFree" => {
      label: "Share for free",
      translation_key: "admin.transaction_types.share_for_free",
      action_button_translation_key: "admin.transaction_types.default_action_button_labels.offer"
    },
    "Swap" => {
      label: "Swap",
      translation_key: "admin.transaction_types.swap",
      action_button_translation_key: "admin.transaction_types.default_action_button_labels.offer"
    }
  }

  module_function

  def create(community, transaction_type_class_name)
    throw "Transaction type #{transaction_type_class_name} not available. Available types are: #{available_types.join(', ')}" unless available_types.include? transaction_type_class_name

    # Create
    transaction_type = create_transaction_type(community, transaction_type_class_name)

    # Locales
    community.locales.each do |locale|
      create_transaction_type_translation(transaction_type, transaction_type_class_name, locale)
    end

    # Categories
    community.categories.each do |category|
      use_in_category(category, transaction_type)
    end

    transaction_type
  end

  def available_types
    TransactionTypeCreator::TRANSACTION_TYPES.map { |type, settings| type }
  end

  def create_transaction_type(community, transaction_type_class_name)
    transaction_type_class = transaction_type_class_name.constantize

    transaction_type = transaction_type_class.new
    transaction_type.community = community
    transaction_type.save!
    community.transaction_types << transaction_type

    transaction_type
  end

  def create_transaction_type_translation(transaction_type, transaction_type_class_name, language)
    transaction_type_description = TRANSACTION_TYPES[transaction_type_class_name]

    TransactionTypeTranslation.create({
      transaction_type_id: transaction_type.id,
      locale: language,
      name: I18n.t(transaction_type_description[:translation_key], :locale => language.to_sym),
      action_button_label: I18n.t(transaction_type_description[:action_button_translation_key], :locale => language.to_sym)
    });
  end

  def use_in_category(category, transaction_type)
    CategoryTransactionType.create(:category_id => category.id, :transaction_type_id => transaction_type.id)
  end

end