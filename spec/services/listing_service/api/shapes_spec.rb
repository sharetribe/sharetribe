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
      price_quantity_placeholder: :time,
      sort_priority: 0,
      basename: "Selling",

      units: [
        {type: :day, quantity_selector: :day},
        {type: :custom, quantity_selector: :number, translation_key: 'my.custom.units.translation'}
      ]
    }

    listings_api.shapes.create(
      community_id: community_id,
      opts: defaults.merge(opts)
    )
  end

  describe "#create" do
    context "success" do
      it "creates new listing shape with day unit" do
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
        expect(shape[:price_quantity_placeholder]).to eql(:time)
        expect(shape[:category_ids]).to eq category_ids
        expect(shape[:name]).to eql("selling")

        units = shape[:units]

        expect(units[0][:type]).to eql(:day)
        expect(units[0][:quantity_selector]).to eql(:day)
        expect(units[1][:type]).to eql(:custom)
        expect(units[1][:quantity_selector]).to eql(:number)
        expect(units[1][:translation_key]).to eql('my.custom.units.translation')
      end

      it "creates new listing shape with piece unit" do
        create_shape_res = create_shape(
          units: [
            {type: :piece, quantity_selector: :number},
            {type: :custom, quantity_selector: :number, translation_key: 'my.custom.units.translation'}
          ]
        )

        expect(create_shape_res.success).to eql(true)

        listing_shape_id = create_shape_res.data[:id]

        res = listings_api.shapes.get(community_id: community_id, listing_shape_id: listing_shape_id)

        expect(res.success).to eql(true)

        shape = res.data

        expect(shape[:community_id]).to eql(community_id)
        expect(shape[:price_enabled]).to eql(true)
        expect(shape[:shipping_enabled]).to eql(true)
        expect(shape[:transaction_process_id]).to eql(transaction_process_id)
        expect(shape[:name_tr_key]).to eql(name_tr_key)
        expect(shape[:action_button_tr_key]).to eql(action_button_tr_key)

        units = shape[:units]

        expect(units[0][:type]).to eql(:piece)
        expect(units[1][:type]).to eql(:custom)
        expect(units[1][:translation_key]).to eql('my.custom.units.translation')
      end
    end

    context "failure" do
      it "validates custom unit" do
        expect { create_shape(
          units: [
            {type: :custom}
          ]
        ) }.to raise_error(ArgumentError)
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
              {type: :custom, quantity_selector: :number, translation_key: 'my.custom.units.translation'}
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
        expect(units[1][:translation_key]).to eql('my.custom.units.translation')
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
        expect(units[1][:translation_key]).to eql('my.custom.units.translation')
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
end
