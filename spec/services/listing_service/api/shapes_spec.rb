# coding: utf-8
require 'spec_helper'

describe ListingService::API::Shapes do

  let(:listings_api) { ListingService::API::Api }
  let(:community_id) { FactoryGirl.create(:community).id }
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

      # TODO Move these to translation service
      translations: [
        { locale: "en", name: "Selling", action_button_label: "Buy" },
        { locale: "fi", name: "Myydään", action_button_label: "Osta" }
      ],
      url_source: "Selling",

      units: [
        {type: :day},
        {type: :custom, translation_key: 'my.custom.units.translation'}
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

        transaction_type_id = create_shape_res.data[:transaction_type_id]

        res = listings_api.shapes.get(community_id: community_id, transaction_type_id: transaction_type_id)

        expect(res.success).to eql(true)

        shape = res.data

        expect(shape[:community_id]).to eql(community_id)
        expect(shape[:price_enabled]).to eql(true)
        expect(shape[:shipping_enabled]).to eql(true)
        expect(shape[:transaction_process_id]).to eql(transaction_process_id)
        expect(shape[:transaction_type_id]).to be_a(Fixnum)
        expect(shape[:name_tr_key]).to eql(name_tr_key)
        expect(shape[:action_button_tr_key]).to eql(action_button_tr_key)
        expect(shape[:price_quantity_placeholder]).to eql(:time)

        units = shape[:units]

        expect(units[0][:type]).to eql(:day)
        expect(units[1][:type]).to eql(:custom)
        expect(units[1][:translation_key]).to eql('my.custom.units.translation')

        # TODO Remove this in the future.
        # Currently also TransactionType is saved
        tt = TransactionType.find(shape[:transaction_type_id])
        expect(tt.community_id).to eql(community_id)
        expect(tt.price_field?).to eql(true)
        expect(tt.shipping_enabled?).to eql(true)
        expect(tt.transaction_process_id).to eql(transaction_process_id)
        expect(tt.name_tr_key).to eql(name_tr_key)
        expect(tt.action_button_tr_key).to eql(action_button_tr_key)
        expect(tt.url).to eql("selling")
        expect(tt.price_quantity_placeholder).to eql("time")

        ## TODO Remove this in the future
        s = ListingShape.where(transaction_type_id: shape[:transaction_type_id]).first
        expect(s.community_id).to eql(community_id)
        expect(s.price_enabled?).to eql(true)
        expect(s.shipping_enabled?).to eql(true)
        expect(s.transaction_process_id).to eql(transaction_process_id)
        expect(s.name_tr_key).to eql(name_tr_key)
        expect(s.action_button_tr_key).to eql(action_button_tr_key)
        expect(s.name).to eql("selling")
        expect(s.price_quantity_placeholder).to eql("time")

        ## TODO Remove this in the future
        expect(ListingUnit.where(listing_shape_id: s.id).count).to eq 2
      end

      it "creates new listing shape with piece unit" do
        create_shape_res = create_shape(
          units: [
            {type: :piece},
            {type: :custom, translation_key: 'my.custom.units.translation'}
          ]
        )

        expect(create_shape_res.success).to eql(true)

        transaction_type_id = create_shape_res.data[:transaction_type_id]

        res = listings_api.shapes.get(community_id: community_id, transaction_type_id: transaction_type_id)

        expect(res.success).to eql(true)

        shape = res.data

        expect(shape[:community_id]).to eql(community_id)
        expect(shape[:price_enabled]).to eql(true)
        expect(shape[:shipping_enabled]).to eql(true)
        expect(shape[:transaction_process_id]).to eql(transaction_process_id)
        expect(shape[:transaction_type_id]).to be_a(Fixnum)
        expect(shape[:name_tr_key]).to eql(name_tr_key)
        expect(shape[:action_button_tr_key]).to eql(action_button_tr_key)

        units = shape[:units]

        expect(units[0][:type]).to eql(:piece)
        expect(units[1][:type]).to eql(:custom)
        expect(units[1][:translation_key]).to eql('my.custom.units.translation')

        # TODO Remove this in the future.
        # Currently also TransactionType is saved
        tt = TransactionType.find(shape[:transaction_type_id])
        expect(tt.community_id).to eql(community_id)
        expect(tt.price_field?).to eql(true)
        expect(tt.shipping_enabled?).to eql(true)
        expect(tt.transaction_process_id).to eql(transaction_process_id)
        expect(tt.name_tr_key).to eql(name_tr_key)
        expect(tt.action_button_tr_key).to eql(action_button_tr_key)

        ## TODO Remove this in the future
        s = ListingShape.where(transaction_type_id: shape[:transaction_type_id]).first
        expect(s.community_id).to eql(community_id)
        expect(s.price_enabled?).to eql(true)
        expect(s.shipping_enabled?).to eql(true)
        expect(s.transaction_process_id).to eql(transaction_process_id)
        expect(s.name_tr_key).to eql(name_tr_key)
        expect(s.action_button_tr_key).to eql(action_button_tr_key)
        expect(s.price_quantity_placeholder).to eql("time")

        ## TODO Remove this in the future
        expect(ListingUnit.where(listing_shape_id: s.id).count).to eq 2
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
    end
  end

  describe "#update" do
    context "success" do
      let(:transaction_type_id) {
        create_shape.data[:transaction_type_id]
      }

      it "updates listing type units and shipping" do
        update_res = listings_api.shapes.update(
          community_id: community_id,
          transaction_type_id: transaction_type_id,
          opts: {
            shipping_enabled: false,
            url_source: "Selling w/o shipping",
            units: [
              {type: :day},
              {type: :custom, translation_key: 'my.custom.units.translation'}
            ]})

        expect(update_res.success).to eql(true)

        shape = update_res.data

        expect(shape[:community_id]).to eql(community_id)
        expect(shape[:price_enabled]).to eql(true)
        expect(shape[:shipping_enabled]).to eql(false)
        expect(shape[:transaction_process_id]).to eql(transaction_process_id)
        expect(shape[:transaction_type_id]).to eql(transaction_type_id)
        expect(shape[:name_tr_key]).to eql(name_tr_key)
        expect(shape[:action_button_tr_key]).to eql(action_button_tr_key)

        units = shape[:units]

        expect(units[0][:type]).to eql(:day)
        expect(units[1][:type]).to eql(:custom)
        expect(units[1][:translation_key]).to eql('my.custom.units.translation')

        # TODO Remove this in the future.
        # Currently also TransactionType is saved
        tt = TransactionType.find(shape[:transaction_type_id])
        expect(tt.community_id).to eql(community_id)
        expect(tt.price_field?).to eql(true)
        expect(tt.shipping_enabled?).to eql(false)
        expect(tt.transaction_process_id).to eql(transaction_process_id)
        expect(tt.name_tr_key).to eql(name_tr_key)
        expect(tt.action_button_tr_key).to eql(action_button_tr_key)
        expect(tt.url).to eql("selling") # URL in not updated

        ## TODO Remove this in the future
        s = ListingShape.where(transaction_type_id: shape[:transaction_type_id]).first
        expect(s.community_id).to eql(community_id)
        expect(s.price_enabled?).to eql(true)
        expect(s.shipping_enabled?).to eql(false)
        expect(s.transaction_process_id).to eql(transaction_process_id)
        expect(s.name_tr_key).to eql(name_tr_key)
        expect(s.action_button_tr_key).to eql(action_button_tr_key)
        expect(tt.url).to eql("selling") # URL is not updated

        ## TODO Remove this in the future
        expect(ListingUnit.where(listing_shape_id: s.id).count).to eq 2
      end
    end

    context "failure" do
      it "can not update non-existing shape" do
        update_res = listings_api.shapes.update(
          community_id: community_id,
          transaction_type_id: 9999,
          opts: {
            units: [{type: :day}]})

        expect(update_res.success).to eql(false)
      end
    end
  end
end
