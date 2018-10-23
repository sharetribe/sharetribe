class ListingShapeTemplates
  Shape = ListingShapeDataTypes::Shape
  KEY_MAP = ListingShapeDataTypes::KEY_MAP

  def initialize(process_summary)
    @process_summary = process_summary
  end

  def label_key_list
    available_templates.map { |tmpl|
      [tmpl[:label], tmpl[:template]]
    }
  end

  def find(key, locales)
    sym_key = key.to_sym
    template = available_templates.find { |tmpl| tmpl[:template] == sym_key }

    return if template.nil?

    with_translations = TranslationServiceHelper.tr_keys_to_form_values(
      entity: template,
      locales: locales,
      key_map: KEY_MAP
    )

    Shape.call(with_translations)
  end

  private

  def available_templates
    @available_templates ||= all.reject { |tmpl|
      tmpl[:template] == :requesting && !@process_summary[:request_available]
    }
  end

  def all
    [
      {
        label: "admin.listing_shapes.templates.selling_products",
        name_tr_key: "admin.transaction_types.sell",
        action_button_tr_key: "admin.transaction_types.default_action_button_labels.sell",
        price_enabled: true,
        shipping_enabled: true,
        online_payments: true,
        template: :selling_products,
        author_is_seller: true,
        units: [{unit_type: 'unit', quantity_selector: :number}]
      },
      {
        label: "admin.listing_shapes.templates.renting_products",
        name_tr_key: "admin.transaction_types.rent",
        action_button_tr_key: "admin.transaction_types.default_action_button_labels.rent",
        price_enabled: true,
        shipping_enabled: false,
        online_payments: true,
        template: :renting_products,
        author_is_seller: true,
        availability: 'booking',
        units: [{unit_type: 'night', quantity_selector: :night}]
      },
      {
        label: "admin.listing_shapes.templates.offering_services",
        name_tr_key: "admin.transaction_types.service",
        action_button_tr_key: "admin.transaction_types.default_action_button_labels.offer",
        price_enabled: true,
        shipping_enabled: false,
        online_payments: true,
        template: :offering_services,
        author_is_seller: true,
        availability: 'booking',
        units: [{unit_type: 'hour', quantity_selector: :number}]
      },
      {
        label: "admin.listing_shapes.templates.giving_things_away",
        name_tr_key: "admin.transaction_types.give",
        action_button_tr_key: "admin.transaction_types.default_action_button_labels.offer",
        price_enabled: false,
        shipping_enabled: false,
        online_payments: false,
        template: :giving_things_away,
        author_is_seller: true,
        units: []
      },
      {
        label: "admin.listing_shapes.templates.requesting",
        name_tr_key: "admin.transaction_types.request",
        action_button_tr_key: "admin.transaction_types.default_action_button_labels.request",
        price_enabled: false,
        shipping_enabled: false,
        online_payments: false,
        template: :requesting,
        author_is_seller: false,
        units: []
      },
      {
        label: "admin.listing_shapes.templates.announcement",
        name_tr_key: "admin.transaction_types.inquiry",
        action_button_tr_key: "admin.transaction_types.default_action_button_labels.inquiry",
        price_enabled: false,
        shipping_enabled: false,
        online_payments: false,
        template:  :announcement,
        author_is_seller: true,
        units: []
      },
      {
        label: "admin.listing_shapes.templates.custom",
        name_tr_key: nil,
        action_button_tr_key: nil,
        price_enabled: false,
        shipping_enabled: false,
        online_payments: false,
        template: :custom,
        author_is_seller: true,
        units: []
      }
    ]
  end

end
