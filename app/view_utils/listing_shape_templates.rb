module ListingShapeTemplates

  module_function

  def all
    [
      {
        label: "admin.listing_shapes.templates.selling_products",
        shape:
          {
            name_tr_key: "admin.transaction_types.sell",
            action_button_tr_key: "admin.transaction_types.default_action_button_labels.sell",
            price_enabled: true,
            shipping_enabled: true,
            online_payments: true,
            transaction_process: { author_is_seller: true },
            template: :selling_products,
            units: []
          }
      },
      {
        label: "admin.listing_shapes.templates.renting_products",
        shape:
          {
            name_tr_key: "admin.transaction_types.rent",
            action_button_tr_key: "admin.transaction_types.default_action_button_labels.rent",
            price_enabled: true,
            shipping_enabled: false,
            online_payments: true,
            transaction_process: { author_is_seller: true },
            template: :renting_products,
            units: [{type: :day, quantity_selector: :day}, {type: :week, quantity_selector: :number}, {type: :month, quantity_selector: :number}]
          }
      },
      {
        label: "admin.listing_shapes.templates.offering_services",
        shape:
          {
            name_tr_key: "admin.transaction_types.service",
            action_button_tr_key: "admin.transaction_types.default_action_button_labels.offer",
            price_enabled: true,
            shipping_enabled: false,
            online_payments: true,
            transaction_process: { author_is_seller: true },
            template: :offering_services,
            units: [{type: :hour, quantity_selector: :number}]
          }
      },
      {
        label: "admin.listing_shapes.templates.giving_things_away",
        shape:
          {
            name_tr_key: "admin.transaction_types.give",
            action_button_tr_key: "admin.transaction_types.default_action_button_labels.offer",
            price_enabled: false,
            shipping_enabled: false,
            online_payments: false,
            transaction_process: { author_is_seller: true },
            template: :giving_things_away,
            units: []
          }
      },
      {
        label: "admin.listing_shapes.templates.requesting",
        shape:
          {
            name_tr_key: "admin.transaction_types.request",
            action_button_tr_key: "admin.transaction_types.default_action_button_labels.request",
            price_enabled: false,
            shipping_enabled: false,
            online_payments: false,
            transaction_process: { author_is_seller: false },
            template: :requesting,
            units: []
          }
      },
      {
        label: "admin.listing_shapes.templates.announcement",
        shape:
          {
            name_tr_key: "admin.transaction_types.inquiry",
            action_button_tr_key: "admin.transaction_types.default_action_button_labels.inquiry",
            price_enabled: false,
            shipping_enabled: false,
            online_payments: false,
            transaction_process: { author_is_seller: true },
            template:  :announcement,
            units: []
          }
      },
      {
        label: "admin.listing_shapes.templates.custom",
        shape:
          {
            name_tr_key: "admin.transaction_types.custom",
            action_button_tr_key: "admin.transaction_types.default_action_button_labels.custom",
            price_enabled: false,
            shipping_enabled: false,
            online_payments: false,
            transaction_process: { author_is_seller: true },
            template: :custom,
            units: []
          }
      }
    ]
  end

end
