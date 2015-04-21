module ListingShapeTemplates

  module_function

  def all
    [
      {
        procees: { author_is_seller: true },
        shape:
          {
            label: "admin.listing_shapes.templates.selling_products",
            template: :selling_products,
            name_tr_key: "admin.transaction_types.sell",
            action_button_tr_key: "admin.transaction_types.default_action_button_labels.sell",
            price_enabled: true,
            shipping_enabled: true,
            online_payments: true,
            units: []
          }
      },
      {
        procees: { author_is_seller: true },
        shape:
          {
            label: "admin.listing_shapes.templates.renting_products",
            template: :renting_products,
            name_tr_key: "admin.transaction_types.rent",
            action_button_tr_key: "admin.transaction_types.default_action_button_labels.rent",
            price_enabled: true,
            shipping_enabled: false,
            online_payments: true,
            units: [{type: :day}, {type: :week}, {type: :month}]
          }
      },
      {
        procees: { author_is_seller: true },
        shape:
          {
            label: "admin.listing_shapes.templates.offering_services",
            template: :offering_services,
            name_tr_key: "admin.transaction_types.service",
            action_button_tr_key: "admin.transaction_types.default_action_button_labels.offer",
            price_enabled: true,
            shipping_enabled: false,
            online_payments: true,
            units: [{type: :hour}]
          }
      },
      {
        procees: { author_is_seller: true },
        shape:
          {
            label: "admin.listing_shapes.templates.giving_things_away",
            template: :giving_things_away,
            name_tr_key: "admin.transaction_types.give",
            action_button_tr_key: "admin.transaction_types.default_action_button_labels.offer",
            price_enabled: false,
            shipping_enabled: false,
            online_payments: false,
            units: []
          }
      },
      {
        procees: { author_is_seller: false },
        shape:
          {
            label: "admin.listing_shapes.templates.requesting",
            template: :requesting,
            name_tr_key: "admin.transaction_types.request",
            action_button_tr_key: "admin.transaction_types.default_action_button_labels.request",
            price_enabled: false,
            shipping_enabled: false,
            online_payments: false,
            units: []
          }
      },
      {
        procees: { author_is_seller: true },
        shape:
          {
            label: "admin.listing_shapes.templates.announcement",
            template:  :announcement,
            name_tr_key: "admin.transaction_types.inquiry",
            action_button_tr_key: "admin.transaction_types.default_action_button_labels.inquiry",
            price_enabled: false,
            shipping_enabled: false,
            online_payments: false,
            units: []
          }
      },
      {
        procees: { author_is_seller: true },
        shape:
          {
            label: "admin.listing_shapes.templates.custom",
            template: :custom,
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
