class ListingShapeTemplates

  def initialize(processes)
    @processes = processes
  end

  def available?(key)
    key = key.to_sym
    all.any? { |tmpl| tmpl[:key] == key }
  end

  def find(key)
    key = key.to_sym
    all.find { |tmpl| tmpl[:key] == key }
  end

  def all
    @all ||= get_available(@processes)
  end

  private

  def get_available(transaction_processes)
    defaults.reject { |tmpl|
      tmpl[:key] == :requesting && !request_process_available
    }
  end

  def request_process_available
    @request_process_available ||= @processes.any? { |tp| tp[:author_is_seller] == false }
  end

  def defaults
    [
      {
        label: "admin.listing_shapes.templates.selling_products",
        key: :selling_products,
        name_tr_key: "admin.transaction_types.sell",
        action_button_tr_key: "admin.transaction_types.default_action_button_labels.sell",
        price_enabled: true,
        shipping_enabled: true,
        online_payments: true,
        author_is_seller: true,
        units: []
      },
      {
        label: "admin.listing_shapes.templates.renting_products",
        key: :renting_products,
        name_tr_key: "admin.transaction_types.rent",
        action_button_tr_key: "admin.transaction_types.default_action_button_labels.rent",
        price_enabled: true,
        shipping_enabled: false,
        online_payments: true,
        author_is_seller: true,
        units: [{type: :day}, {type: :week}, {type: :month}]
      },
      {
        label: "admin.listing_shapes.templates.offering_services",
        key: :offering_services,
        name_tr_key: "admin.transaction_types.service",
        action_button_tr_key: "admin.transaction_types.default_action_button_labels.offer",
        price_enabled: true,
        shipping_enabled: false,
        online_payments: true,
        author_is_seller: true,
        units: [{type: :hour}]
      },
      {
        label: "admin.listing_shapes.templates.giving_things_away",
        key: :giving_things_away,
        name_tr_key: "admin.transaction_types.give",
        action_button_tr_key: "admin.transaction_types.default_action_button_labels.offer",
        price_enabled: false,
        shipping_enabled: false,
        online_payments: false,
        author_is_seller: true,
        units: []
      },
      {
        label: "admin.listing_shapes.templates.requesting",
        key: :requesting,
        name_tr_key: "admin.transaction_types.request",
        action_button_tr_key: "admin.transaction_types.default_action_button_labels.request",
        price_enabled: false,
        shipping_enabled: false,
        online_payments: false,
        author_is_seller: false,
        units: []
      },
      {
        label: "admin.listing_shapes.templates.announcement",
        key:  :announcement,
        name_tr_key: "admin.transaction_types.inquiry",
        action_button_tr_key: "admin.transaction_types.default_action_button_labels.inquiry",
        price_enabled: false,
        shipping_enabled: false,
        online_payments: false,
        author_is_seller: true,
        units: []
      },
      {
        label: "admin.listing_shapes.templates.custom",
        key: :custom,
        name_tr_key: "admin.transaction_types.custom",
        action_button_tr_key: "admin.transaction_types.default_action_button_labels.custom",
        price_enabled: false,
        shipping_enabled: false,
        online_payments: false,
        author_is_seller: true,
        units: []
      }
    ]
  end

end
