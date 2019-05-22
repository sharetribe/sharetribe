#
# Helper module to create transaction types. Can be used from the application code (super admin controller) or from
# console
#
# Console usage:
#
# c = Community.find(1234)
# TransactionTyperCreator.create(c, "Sell")
#
class TransactionTypeCreator

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
      none: {
        price_enabled: true,
        availability: ListingShape::AVAILABILITY_NONE,
        units: [
          {unit_type: ListingUnit::DAY, quantity_selector: 'day', kind: 'time'}
        ]
      },
      preauthorize: {
        price_enabled: true,
        availability: ListingShape::AVAILABILITY_BOOKING,
        units: [
          {unit_type: ListingUnit::NIGHT, quantity_selector: 'night', kind: 'time'}
        ]
      }
    },
    "Request" => {
      price_enabled: false
    },
    "Sell" => {
      none: {
        price_enabled: true,
        availability: ListingShape::AVAILABILITY_NONE,
        units: [
          {unit_type: ListingUnit::UNIT, quantity_selector: 'number', kind: 'quantity'}
        ]
      },
      preauthorize: {
        price_enabled: true,
        availability: ListingShape::AVAILABILITY_NONE,
        units: [
          {unit_type: ListingUnit::UNIT, quantity_selector: 'number', kind: 'quantity'}
        ]
      }
    },
    "Service" => {
      none: {
        price_enabled: true,
        availability: ListingShape::AVAILABILITY_NONE,
        units: [
          {unit_type: ListingUnit::HOUR, quantity_selector: 'number', kind: 'time'}
        ]
      },
      preauthorize: {
        price_enabled: true,
        availability: ListingShape::AVAILABILITY_BOOKING,
        units: [
          {unit_type: ListingUnit::HOUR, quantity_selector: 'number', kind: 'time'}
        ]
      }
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
      none: {
        label: "Rent",
        translation_key: "admin.transaction_types.rent_wo_online_payment",
        action_button_translation_key: "admin.transaction_types.default_action_button_labels.rent",
      },
      preauthorize: {
        label: "Rent",
        translation_key: "admin.transaction_types.rent_w_online_payment",
        action_button_translation_key: "admin.transaction_types.default_action_button_labels.rent",
      },
    },
    "Request" => {
      label: "Request",
      translation_key: "admin.transaction_types.request",
      action_button_translation_key: "admin.transaction_types.default_action_button_labels.request",
    },
    "Sell" => {
      none: {
        label: "Sell",
        translation_key: "admin.transaction_types.sell_wo_online_payment",
        action_button_translation_key: "admin.transaction_types.default_action_button_labels.sell",
      },
      preauthorize: {
        label: "Sell",
        translation_key: "admin.transaction_types.sell_w_online_payment",
        action_button_translation_key: "admin.transaction_types.default_action_button_labels.sell",
      },
    },
    "Service" => {
      none: {
        label: "Service",
        translation_key: "admin.transaction_types.service_wo_online_payment",
        action_button_translation_key: "admin.transaction_types.default_action_button_labels.offer",
      },
      preauthorize: {
        label: "Service",
        translation_key: "admin.transaction_types.service_w_online_payment",
        action_button_translation_key: "admin.transaction_types.default_action_button_labels.offer",
      },
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

  class << self
    def create(community, marketplace_type)
      transaction_type = select_listing_shape_template(marketplace_type)
      enable_shipping = marketplace_type.or_else("product") == "product"
      throw "Transaction type '#{transaction_type}' not available. Available types are: #{DEFAULTS.keys.join(', ')}" unless DEFAULTS.keys.include? transaction_type
      author_is_seller = transaction_type != "Request"

      transaction_processes = TransactionProcess.where(community_id: community.id, author_is_seller: author_is_seller)
      transaction_processes.each do |transaction_process|
        new(
          community: community,
          transaction_type: transaction_type,
          enable_shipping: enable_shipping,
          author_is_seller: author_is_seller,
          transaction_process: transaction_process
        ).create_listing_shape
      end
    end

    def select_listing_shape_template(type)
     case type.or_else("product")
     when "rental"
      "Rent"
     when "service"
      "Service"
     else # also "product" goes to this default
      "Sell"
     end
    end
  end

  private

  attr_reader :community, :transaction_type, :enable_shipping,
    :author_is_seller, :transaction_process

  public

  def initialize(community:, transaction_type:, enable_shipping:,
                author_is_seller:, transaction_process:)
    @community = community
    @transaction_type = transaction_type
    @enable_shipping = enable_shipping
    @author_is_seller = author_is_seller
    @transaction_process = transaction_process
  end

  def create_listing_shape
    # Save name & action_button_label to TranslationService
    translations = TRANSLATIONS[transaction_type][transaction_process.process] || TRANSLATIONS[transaction_type]
    name_group =
      {
        translations: community.locales.map do |locale|
          {
            locale: locale,
            translation: I18n.t(translations[:translation_key], :locale => locale.to_sym, raise: true)
          }
        end
      }
    action_button_group =
      {
        translations: community.locales.map do |locale|
          {
            locale: locale,
            translation: I18n.t(translations[:action_button_translation_key], :locale => locale.to_sym, raise: true)
          }
        end
      }
    created_translations = TranslationService::API::Api.translations.create(community.id, [name_group, action_button_group])
    name_tr_key, action_button_tr_key = created_translations[:data].map { |translation| translation[:translation_key] }

    defaults = DEFAULTS[transaction_type][transaction_process.process] || DEFAULTS[transaction_type]

    # Create

    translations = community.locales.map do |locale|
      {
        locale: locale,
        name: I18n.t(translations[:translation_key], :locale => locale.to_sym),
        action_button_label: I18n.t(translations[:action_button_translation_key], :locale => locale.to_sym)
      }
    end

    shape_opts = defaults.merge(
      transaction_process_id: transaction_process.id,
      name_tr_key: name_tr_key,
      action_button_tr_key: action_button_tr_key,
      translations: translations,
      shipping_enabled: enable_shipping,
      basename: translations.find { |t| t[:locale] == community.default_locale }[:name]
    )
    ListingShape.create_with_opts(community: community, opts: shape_opts)
  end
end
