describe ListingFormViewUtils do
  describe "#filter" do
    def expect_filter(params, shape_opts)
      shape_defaults = {
        price_enabled: true,
        units: []
      }

      expect(ListingFormViewUtils.filter(params, shape_defaults.merge(shape_opts)))
    end

    it "filters fields that do not belong to the shape" do
      expect_filter({price: "50.0"}, {price_enabled: true}).to include(:price)
      expect_filter({price: "50.0"}, {price_enabled: false}).not_to include(:price)

      expect_filter({currency: "EUR"}, {price_enabled: true}).to include(:currency)
      expect_filter({currency: "EUR"}, {price_enabled: false}).not_to include(:currency)

      expect_filter({unit_type: :day}, {units: [{type: :day, quantity_selector: :number}]}).to include(:unit_type)
      expect_filter({unit_type: :day}, {units: []}).not_to include(:unit_type)

      expect_filter({delivery_methods: ["shipping"]}, {shipping_enabled: true}).to include(:delivery_methods)
      expect_filter({delivery_methods: ["shipping"]}, {shipping_enabled: false}).not_to include(:delivery_methods)

      expect_filter({shipping_price: "50.00"}, {shipping_enabled: true}).to include(:shipping_price)
      expect_filter({shipping_price: "50.00"}, {shipping_enabled: false}).not_to include(:shipping_price)

      expect_filter({shipping_price_additional: "50.00"}, {shipping_enabled: true}).to include(:shipping_price_additional)
      expect_filter({shipping_price_additional: "50.00"}, {shipping_enabled: false}).not_to include(:shipping_price_additional)
    end
  end

  describe "#validate" do
    def validate(params, shape_opts)
      shape_defaults = {
        units: []
      }
      ListingFormViewUtils.validate(params, shape_defaults.merge(shape_opts))
    end

    def expect_valid(params, shape_opts)
      expect(validate(params, shape_opts).success).to eq true
    end

    def expect_error(params, shape_opts, *errors)
      raise ArgumentError.new("Expecting error codes array") if errors.empty?

      res = validate(params, shape_opts)
      expect(res.success).to eq false
      errors.each { |error_code|
        expect(res.data).to include(error_code)
      }
    end

    it "validates the params" do
      expect_valid({price: "50.00", currency: "EUR"}, {price_enabled: true})
      expect_error({price: "50.00"}, {price_enabled: true}, :currency_required)
      expect_error({currency: "EUR"}, {price_enabled: true}, :price_required)
      expect_error({}, {price_enabled: true}, :price_required, :currency_required)

      expect_valid({unit_type: :day, quantity_selector: :day}, {units: [{type: :day, quantity_selector: :day}]})
      expect_valid({}, {units: []})
      expect_error({unit_type: :night}, {units: [{type: :day, quantity_selector: :day}]}, :unit_does_not_belong)
      expect_error({unit_type: :day, quantity_selector: :number}, {units: [{type: :day, quantity_selector: :day}]}, :unit_does_not_belong)
      expect_error({}, {units: [{type: :day, quantity_selector: :day}]}, :unit_required)

      expect_valid({delivery_methods: ["shipping", "pickup"]}, {shipping_enabled: true})
      expect_error({delivery_methods: []}, {shipping_enabled: true}, :delivery_method_required)
      expect_error({delivery_methods: ["homedelivery"]}, {shipping_enabled: true}, :unknown_delivery_method)
    end
  end
end

