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

  DEFAULTS = {
    "Give" => {
      price_field: false
    },
    "Inquiry" => {
      price_field: false
    },
    "Lend" => {
      price_field: false
    },
    "Rent" => {
      price_field: true,
      price_per: "day"
    },
    "Request" => {
      price_field: false,
    },
    "Sell" => {
      price_field: true
    },
    "Service" => {
      price_field: true,
      price_per: "day"
    },
    "ShareForFree" => {
      price_field: false
    },
    "Swap" => {
      price_field: false
    }
  }

  TRANSLATIONS = {
    "Give" => {
      label: "Give",
      translation_key: "admin.transaction_types.give",
      action_button_translation_key: "admin.transaction_types.default_action_button_labels.offer",
    },
    "Inquiry" => {
      label: "Inquiry",
      translation_key: "admin.transaction_types.inquiry",
      action_button_translation_key: "admin.transaction_types.default_action_button_labels.inquiry",
    },
    "Lend" => {
      label: "Lend",
      translation_key: "admin.transaction_types.lend",
      action_button_translation_key: "admin.transaction_types.default_action_button_labels.offer",
    },
    "Rent" => {
      label: "Rent",
      translation_key: "admin.transaction_types.rent",
      action_button_translation_key: "admin.transaction_types.default_action_button_labels.rent",
    },
    "Request" => {
      label: "Request",
      translation_key: "admin.transaction_types.request",
      action_button_translation_key: "admin.transaction_types.default_action_button_labels.request",
    },
    "Sell" => {
      label: "Sell",
      translation_key: "admin.transaction_types.sell",
      action_button_translation_key: "admin.transaction_types.default_action_button_labels.sell",
    },
    "Service" => {
      label: "Service",
      translation_key: "admin.transaction_types.service",
      action_button_translation_key: "admin.transaction_types.default_action_button_labels.offer",
    },
    "ShareForFree" => {
      label: "Share for free",
      translation_key: "admin.transaction_types.share_for_free",
      action_button_translation_key: "admin.transaction_types.default_action_button_labels.offer",
    },
    "Swap" => {
      label: "Swap",
      translation_key: "admin.transaction_types.swap",
      action_button_translation_key: "admin.transaction_types.default_action_button_labels.offer",
    }
  }

  TRANSACTION_PROCESSES = [:none, :preauthorize, :postpay]

  module_function

  def create(community, transaction_type_class_name, process, enable_shipping)
    throw "Transaction type '#{transaction_type_class_name}' not available. Available types are: #{available_types.join(', ')}" unless available_types.include? transaction_type_class_name
    throw "Transaction process '#{process}' not available. Available processes are: #{TRANSACTION_PROCESSES.join(', ')}" unless TRANSACTION_PROCESSES.include? process.to_sym

    author_is_seller = transaction_type_class_name != "Request"
    transaction_process = get_or_create_transaction_process(community_id: community.id, process: process, author_is_seller: author_is_seller)

    translations = TRANSLATIONS[transaction_type_class_name]
    defaults = DEFAULTS[transaction_type_class_name]

    # Create
    transaction_type = community.transaction_types.build(
      defaults.merge(transaction_process_id: transaction_process[:id], shipping_enabled: enable_shipping)
    )

    # Locales
    community.locales.each do |locale|

      transaction_type.translations.build({
        locale: locale,
        name: I18n.t(translations[:translation_key], :locale => locale.to_sym),
        action_button_label: I18n.t(translations[:action_button_translation_key], :locale => locale.to_sym)
      })
    end

    transaction_type.save!

    # Save name & action_button_label to TranslationService
    name_group =
      { translation_key: "transaction_type_translation.name.#{transaction_type.id}",
        translations: community.locales.map { |locale|
          {
            locale: locale,
            translation: I18n.t(translations[:translation_key], :locale => locale.to_sym)
          }
        }
      }
    action_button_group =
      { translation_key: "transaction_type_translation.action_button_label.#{transaction_type.id}",
        translations: community.locales.map { |locale|
          {
            locale: locale,
            translation: I18n.t(translations[:action_button_translation_key], :locale => locale.to_sym)
          }
        }
      }
    created_translations = TranslationService::API::Api.translations.create(community.id, [name_group, action_button_group])
    result = created_translations[:data]
    transaction_type[:name_tr_key] =          result.at(0)[:translation_key]
    transaction_type[:action_button_tr_key] = result.at(1)[:translation_key]
    transaction_type.save!

    # Categories
    community.categories.each do |category|
      use_in_category(category, transaction_type)
    end

    transaction_type
  end

  def available_types
    TransactionTypeCreator::DEFAULTS.map { |type, _| type }
  end

  def use_in_category(category, transaction_type)
    CategoryTransactionType.create(:category_id => category.id, :transaction_type_id => transaction_type.id)
  end

  def get_or_create_transaction_process(community_id:, process:, author_is_seller:)
    TransactionService::API::Api.processes.get(community_id: community_id)
      .maybe
      .map { |processes|
        processes.find { |p| p[:process] == process && p[:author_is_seller] == author_is_seller }
      }
      .or_else {
        TransactionService::API::Api.processes.create(
          community_id: community_id,
          process: process,
          author_is_seller: author_is_seller
        ).data
      }
  end
end
