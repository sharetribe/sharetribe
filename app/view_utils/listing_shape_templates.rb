module ListingShapeTemplates

  module_function

  def all
    [
      {
        template: :selling_products,
        label: "admin.listing_shapes.templates.selling_products",
        process: { author_is_seller: true },
        shape:
          {
            name_tr_key: "admin.transaction_types.sell",
            action_button_tr_key: "admin.transaction_types.default_action_button_labels.sell",
            price_enabled: true,
            shipping_enabled: true,
            online_payments: true,
            units: []
          }
      },
      {
        template: :renting_products,
        label: "admin.listing_shapes.templates.renting_products",
        process: { author_is_seller: true },
        shape:
          {
            name_tr_key: "admin.transaction_types.rent",
            action_button_tr_key: "admin.transaction_types.default_action_button_labels.rent",
            price_enabled: true,
            shipping_enabled: false,
            online_payments: true,
            units: [{type: :day}, {type: :week}, {type: :month}]
          }
      },
      {
        template: :offering_services,
        label: "admin.listing_shapes.templates.offering_services",
        process: { author_is_seller: true },
        shape:
          {
            name_tr_key: "admin.transaction_types.service",
            action_button_tr_key: "admin.transaction_types.default_action_button_labels.offer",
            price_enabled: true,
            shipping_enabled: false,
            online_payments: true,
            units: [{type: :hour}]
          }
      },
      {
        template: :giving_things_away,
        label: "admin.listing_shapes.templates.giving_things_away",
        process: { author_is_seller: true },
        shape:
          {
            name_tr_key: "admin.transaction_types.give",
            action_button_tr_key: "admin.transaction_types.default_action_button_labels.offer",
            price_enabled: false,
            shipping_enabled: false,
            online_payments: false,
            units: []
          }
      },
      {
        template: :requesting,
        label: "admin.listing_shapes.templates.requesting",
        process: { author_is_seller: false },
        shape:
          {
            name_tr_key: "admin.transaction_types.request",
            action_button_tr_key: "admin.transaction_types.default_action_button_labels.request",
            price_enabled: false,
            shipping_enabled: false,
            online_payments: false,
            units: []
          }
      },
      {
        template:  :announcement,
        label: "admin.listing_shapes.templates.announcement",
        process: { author_is_seller: true },
        shape:
          {
            name_tr_key: "admin.transaction_types.inquiry",
            action_button_tr_key: "admin.transaction_types.default_action_button_labels.inquiry",
            price_enabled: false,
            shipping_enabled: false,
            online_payments: false,
            units: []
          }
      },
      {
        template: :custom,
        label: "admin.listing_shapes.templates.custom",
        procees: { author_is_seller: true },
        shape:
          {
            name_tr_key: "admin.transaction_types.custom",
            action_button_tr_key: "admin.transaction_types.default_action_button_labels.custom",
            price_enabled: false,
            shipping_enabled: false,
            online_payments: false,
            units: []
          }
      }
    ]
  end

end
