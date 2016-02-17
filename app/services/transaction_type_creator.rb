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
      price_enabled: false
    },
    "Inquiry" => {
      price_enabled: false
    },
    "Lend" => {
      price_enabled: false
    },
    "Rent" => {
      price_enabled: true,
      units: [
        {type: :day, quantity_selector: :day}
      ]
    },
    "Request" => {
      price_enabled: false
    },
    "Sell" => {
      price_enabled: true
    },
    "Service" => {
      price_enabled: true,
      units: [
        {type: :day, quantity_selector: :day}
      ]
    },
    "ShareForFree" => {
      price_enabled: false
    },
    "Swap" => {
      price_enabled: false
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

    # Save name & action_button_label to TranslationService
    translations = TRANSLATIONS[transaction_type_class_name]
    name_group =
      {
        translations: community.locales.map do |locale|
          {
            locale: locale,
            translation: I18n.t(translations[:translation_key], :locale => locale.to_sym)
          }
        end
      }
    action_button_group =
      {
        translations: community.locales.map do |locale|
          {
            locale: locale,
            translation: I18n.t(translations[:action_button_translation_key], :locale => locale.to_sym)
          }
        end
      }
    created_translations = TranslationService::API::Api.translations.create(community.id, [name_group, action_button_group])
    name_tr_key, action_button_tr_key = created_translations[:data].map { |translation| translation[:translation_key] }

    defaults = DEFAULTS[transaction_type_class_name]

    # Create
    listings_api = ListingService::API::Api

    translations = community.locales.map do |locale|
      {
        locale: locale,
        name: I18n.t(translations[:translation_key], :locale => locale.to_sym),
        action_button_label: I18n.t(translations[:action_button_translation_key], :locale => locale.to_sym)
      }
    end

    shape_opts = defaults.merge(
      transaction_process_id: transaction_process[:id],
      name_tr_key: name_tr_key,
      action_button_tr_key: action_button_tr_key,
      translations: translations,
      shipping_enabled: enable_shipping,
      basename: translations.find { |t| t[:locale] == community.default_locale }[:name]
    )

    shape_res = listings_api.shapes.create(
      community_id: community.id,
      opts: shape_opts
    )

    raise ArgumentError.new("Could not create new shape: #{shape_opts}") unless shape_res.success

    shape_res.data
  end

  def available_types
    TransactionTypeCreator::DEFAULTS.map { |type, _| type }
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
