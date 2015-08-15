# coding: utf-8
require 'spec_helper'

describe ListingService::API::Shapes do

  let(:listings_api) { ListingService::API::Api }
  let(:community_id) { 333 }
  let!(:category_ids) {
    translations = [{locale: :en, name: "Test category"}]
    (0..2).map {
      listings_api.categories.create(
        community_id: 333, opts: {
          translations: translations,
          basename: "Test category"
        }).data[:id]
    }

  }
  let(:transaction_process_id) { 555 }
  let(:name_tr_key) { "listing_shape.name.123.translation" }
  let(:action_button_tr_key) { "listing_shape.action_button.123.translation" }


  def create_shape(opts = {})
    defaults = {
      price_enabled: true,
      shipping_enabled: true,
      transaction_process_id: transaction_process_id,
      name_tr_key: name_tr_key,
      action_button_tr_key: action_button_tr_key,
      basename: "Selling",

      units: [
        {
          type: :day,
          quantity_selector: :day
        },
        {
          type: :custom,
          kind: :quantity,
          quantity_selector: :number,
          name_tr_key: 'my.custom.units.translation',
          selector_tr_key: 'my.custom.selector.translation'
        }
      ]
    }

    listings_api.shapes.create(
      community_id: community_id,
      opts: defaults.merge(opts)
    )
  end

  describe "#create" do
    context "success" do
      it "creates new listing shape with units" do
        create_shape_res = create_shape()

        expect(create_shape_res.success).to eql(true)

        listing_shape_id = create_shape_res.data[:id]

        res = listings_api.shapes.get(community_id: community_id, listing_shape_id: listing_shape_id, include_categories: true)

        expect(res.success).to eql(true)

        shape = res.data

        expect(shape[:id]).to be_a(Fixnum)
        expect(shape[:community_id]).to eql(community_id)
        expect(shape[:price_enabled]).to eql(true)
        expect(shape[:shipping_enabled]).to eql(true)
        expect(shape[:transaction_process_id]).to eql(transaction_process_id)
        expect(shape[:name_tr_key]).to eql(name_tr_key)
        expect(shape[:action_button_tr_key]).to eql(action_button_tr_key)
        expect(shape[:category_ids].sort).to eq category_ids.sort
        expect(shape[:name]).to eql("selling")

        units = shape[:units]

        expect(units[0][:type]).to eql(:day)
        expect(units[0][:quantity_selector]).to eql(:day)
        expect(units[1][:type]).to eql(:custom)
        expect(units[1][:kind]).to eql(:quantity)
        expect(units[1][:quantity_selector]).to eql(:number)
        expect(units[1][:name_tr_key]).to eql('my.custom.units.translation')
        expect(units[1][:selector_tr_key]).to eql('my.custom.selector.translation')
      end
    end

    it "uses default basename for url if the name results in emtpy string" do
      create_shape_res = create_shape(
        basename: "!!"
      )
      expect(create_shape_res.success).to eql(true)
      shape = create_shape_res.data
      expect(shape[:name]).to eql("order_type")
    end

    it "creates meaningful default sort priorities" do
      expect(create_shape().data[:sort_priority]).to eq 0
      expect(create_shape().data[:sort_priority]).to eq 1
      expect(create_shape().data[:sort_priority]).to eq 2
    end

    context "failure" do
      let(:valid_unit) {
        {
          type: :custom,
          quantity_selector: :number,
          kind: :time,
          name_tr_key: "name_tr",
          selector_tr_key: "selector_tr"
        }
      }

      it "passes for valid unit" do
        expect { create_shape(units: [valid_unit])}.not_to raise_error
      end

      it "validates custom unit without mandatory fields" do
        [:type, :quantity_selector, :kind, :name_tr_key, :selector_tr_key].each { |field|
          expect { create_shape(units: [valid_unit.except(field)]) }.to raise_error(ArgumentError), "Expected error, field: #{field}"
        }
      end
    end
  end

  describe "#get" do
    context "success" do
      it "gets all by community id" do
        3.times { create_shape }

        get_res = listings_api.shapes.get(community_id: community_id)

        expect(get_res.success).to eq(true)
        expect(get_res.data.length).to eq(3)
      end

      it "gets by name" do
        shape = create_shape.data

        get_res = listings_api.shapes.get(community_id: community_id, name: shape[:name])

        expect(get_res.success).to eq(true)
        expect(get_res.data[:id]).to eq(shape[:id])
      end

      it "respects the sort priority" do
        [["sell", 10], ["rent", 0], ["request", 5]].each { |(name, prio)|
          create_shape(basename: name, sort_priority: prio)
        }

        shape_names = listings_api.shapes.get(community_id: community_id).data.map { |s| [s[:name], s[:sort_priority]] }
        expect(shape_names).to eq [["rent", 0], ["request", 5], ["sell", 10]]
      end
    end
  end

  describe "#update" do
    context "success" do
      let(:listing_shape_id) {
        create_shape.data[:id]
      }

      it "updates listing type units and shipping" do
        update_res = listings_api.shapes.update(
          community_id: community_id,
          listing_shape_id: listing_shape_id,
          opts: {
            shipping_enabled: false,
            basename: "Selling w/o shipping",
            transaction_process_id: 987,
            units: [
              {type: :day, quantity_selector: :number},
              {type: :custom, kind: :time, quantity_selector: :number, name_tr_key: 'my.custom.units.translation', selector_tr_key: 'my.custom.selector.translation'}
            ]})

        expect(update_res.success).to eql(true)

        shape = listings_api.shapes.get(community_id: community_id, listing_shape_id: listing_shape_id).data

        expect(shape[:community_id]).to eql(community_id)
        expect(shape[:price_enabled]).to eql(true)
        expect(shape[:shipping_enabled]).to eql(false)
        expect(shape[:transaction_process_id]).to eql(987)
        expect(shape[:name_tr_key]).to eql(name_tr_key)
        expect(shape[:action_button_tr_key]).to eql(action_button_tr_key)

        units = shape[:units]

        expect(units[0][:type]).to eql(:day)
        expect(units[0][:quantity_selector]).to eql(:number)
        expect(units[1][:type]).to eql(:custom)
        expect(units[1][:name_tr_key]).to eql('my.custom.units.translation')
        expect(units[1][:selector_tr_key]).to eql('my.custom.selector.translation')
      end

      it "updates only one field" do
        update_res = listings_api.shapes.update(
          community_id: community_id,
          listing_shape_id: listing_shape_id,
          opts: { shipping_enabled: false }
        )

        expect(update_res.success).to eql(true)

        shape = listings_api.shapes.get(community_id: community_id, listing_shape_id: listing_shape_id).data

        expect(shape[:community_id]).to eql(community_id)
        expect(shape[:price_enabled]).to eql(true)
        expect(shape[:shipping_enabled]).to eql(false)
        expect(shape[:transaction_process_id]).to eql(transaction_process_id)
        expect(shape[:name_tr_key]).to eql(name_tr_key)
        expect(shape[:action_button_tr_key]).to eql(action_button_tr_key)

        units = shape[:units]

        expect(units[0][:type]).to eql(:day)
        expect(units[1][:type]).to eql(:custom)
        expect(units[1][:name_tr_key]).to eql('my.custom.units.translation')
        expect(units[1][:selector_tr_key]).to eql('my.custom.selector.translation')
      end

      it "updates by name" do
        shape = create_shape.data

        expect(shape[:shipping_enabled]).to eql(true)

        update_res = listings_api.shapes.update(
          community_id: community_id,
          name: shape[:name],
          opts: { shipping_enabled: false })

        expect(update_res.success).to eq(true)
        expect(update_res.data[:shipping_enabled]).to eq(false)
      end
    end

    context "failure" do
      it "can not update non-existing shape" do
        update_res = listings_api.shapes.update(
          community_id: community_id,
          listing_shape_id: 9999,
          opts: {
            units: [{type: :day, quantity_selector: :day}]})

        expect(update_res.success).to eql(false)
      end
    end
  end

  describe "#delete" do
    let(:id) { create_shape.data[:id] }
    let(:name) { create_shape.data[:name] }

    context "success" do
      it "deletes the shape" do
        first_get = listings_api.shapes.get(
          community_id: community_id,
          listing_shape_id: id)

        expect(first_get.success).to eq true

        delete_res = listings_api.shapes.delete(
          community_id: community_id,
          listing_shape_id: id)

        expect(delete_res.success).to eq true
        expect(delete_res.data[:id]).to eq id

        second_get = listings_api.shapes.get(
          community_id: community_id,
          listing_shape_id: id)

        expect(second_get.success).to eq false
      end

      it "deletes by name" do
        first_get = listings_api.shapes.get(
          community_id: community_id,
          name: name)

        expect(first_get.success).to eq true

        delete_res = listings_api.shapes.delete(
          community_id: community_id,
          name: name)

        expect(delete_res.success).to eq true
        expect(delete_res.data[:name]).to eq name

        second_get = listings_api.shapes.get(
          community_id: community_id,
          name: name)

        expect(second_get.success).to eq false

      end
    end

    context "failure" do
      it "fails if shape doesn't exist" do
        delete_res = listings_api.shapes.delete(
          community_id: community_id,
          listing_shape_id: 999)

        expect(delete_res.success).to eq false
      end

      it "fails if shape doesn't exist in the community" do
        delete_res = listings_api.shapes.delete(
          community_id: 999,
          listing_shape_id: id)

        expect(delete_res.success).to eq false

      end
    end

  end
end
