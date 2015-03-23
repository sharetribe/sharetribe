# coding: utf-8
require 'spec_helper'

describe ListingService::API::Shapes do

  let(:listings_api) { ListingService::API::Api }
  let(:community_id) { FactoryGirl.create(:community).id }
  let(:transaction_process_id) { 555 }
  let(:name_tr_key) { "listing_shape.name.123.translation" }
  let(:action_button_tr_key) { "listing_shape.action_button.123.translation" }

  describe "#create" do
    context "success" do
      it "creates new listing shape with day unit" do
        create_shape_res = listings_api.shapes.create(
          community_id: community_id,
          opts: {
            price_enabled: true,
            shipping_enabled: true,
            transaction_process_id: transaction_process_id,
            name_tr_key: name_tr_key,
            action_button_tr_key: action_button_tr_key,

            # TODO Move these to translation service
            translations: [
              { locale: "en", name: "Selling", action_button_label: "Buy" },
              { locale: "fi", name: "Myydään", action_button_label: "Osta" }
            ],

            units: [
              {type: :day},
              # TODO Enable me {type: :custom, translation_key: 'my.custom.units.translation'}
            ]
          }
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

        expect(units[0][:type]).to eql(:day)
        # TODO Enable me expect(units[1][:type]).to eql(:custom)
        # TODO Enable me expect(units[1][:translation_key]).to eql('my.custom.units.translation')

        # TODO Remove this in the future.
        # Currently also TransactionType is saved
        tt = TransactionType.find(shape[:transaction_type_id])
        expect(tt.community_id).to eql(community_id)
        expect(tt.price_field?).to eql(true)
        expect(tt.shipping_enabled?).to eql(true)
        expect(tt.transaction_process_id).to eql(transaction_process_id)
        expect(tt.price_per).to eql("day")
        expect(tt.name_tr_key).to eql(name_tr_key)
        expect(tt.action_button_tr_key).to eql(action_button_tr_key)
      end

      it "creates new listing shape with piece unit" do
        create_shape_res = listings_api.shapes.create(
          community_id: community_id,
          opts: {
            price_enabled: true,
            transaction_process_id: transaction_process_id,
            name_tr_key: name_tr_key,
            action_button_tr_key: action_button_tr_key,
            shipping_enabled: true,

            # TODO Move these to translation service
            translations: [
              { locale: "en", name: "Selling", action_button_label: "Buy" },
              { locale: "fi", name: "Myydään", action_button_label: "Osta" }
            ],

            units: [
              {type: :piece},
              # TODO Enable me {type: :custom, translation_key: 'my.custom.units.translation'}
            ]
          }
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
        # TODO Enable me expect(units[1][:type]).to eql(:custom)
        # TODO Enable me expect(units[1][:translation_key]).to eql('my.custom.units.translation')

        # TODO Remove this in the future.
        # Currently also TransactionType is saved
        tt = TransactionType.find(shape[:transaction_type_id])
        expect(tt.community_id).to eql(community_id)
        expect(tt.price_field?).to eql(true)
        expect(tt.shipping_enabled?).to eql(true)
        expect(tt.transaction_process_id).to eql(transaction_process_id)
        expect(tt.price_per).to eql(nil)
        expect(tt.name_tr_key).to eql(name_tr_key)
        expect(tt.action_button_tr_key).to eql(action_button_tr_key)
      end
    end
  end

  describe "#update" do
    context "success" do
      let(:transaction_type_id) {
        shapes.create(
          community_id: community_id,
          opts: {
            price_enabled: true,
            shipping_enabled: true,
            transaction_process_id: transaction_process_id,
            name_tr_key: name_tr_key,
            action_button_tr_key: action_button_tr_key,

            # TODO Move these to translation service
            translations: [
              { locale: "en", name: "Selling", action_button_label: "Buy" },
              { locale: "fi", name: "Myydään", action_button_label: "Osta" }
            ],

            units: []
          }
        ).data[:transaction_type_id]
      }

      it "updates listing type units" do
        update_res = shapes.update(
          community_id: community_id,
          transaction_type_id: transaction_type_id,
          opts: {
            units: [{type: :day}]})

        expect(update_res.success).to eql(true)

        shape = update_res.data

        expect(shape[:community_id]).to eql(community_id)
        expect(shape[:price_enabled]).to eql(true)
        expect(shape[:shipping_enabled]).to eql(true)
        expect(shape[:transaction_process_id]).to eql(transaction_process_id)
        expect(shape[:transaction_type_id]).to eql(transaction_type_id)
        expect(shape[:name_tr_key]).to eql(name_tr_key)
        expect(shape[:action_button_tr_key]).to eql(action_button_tr_key)

        units = shape[:units]

        expect(units[0][:type]).to eql(:day)
        # TODO Enable me expect(units[1][:type]).to eql(:custom)
        # TODO Enable me expect(units[1][:translation_key]).to eql('my.custom.units.translation')

        # TODO Remove this in the future.
        # Currently also TransactionType is saved
        tt = TransactionType.find(shape[:transaction_type_id])
        expect(tt.community_id).to eql(community_id)
        expect(tt.price_field?).to eql(true)
        expect(tt.shipping_enabled?).to eql(true)
        expect(tt.transaction_process_id).to eql(transaction_process_id)
        expect(tt.price_per).to eql("day")
        expect(tt.name_tr_key).to eql(name_tr_key)
        expect(tt.action_button_tr_key).to eql(action_button_tr_key)
      end
    end

    context "failure" do
      it "can not update non-existing shape" do
        update_res = shapes.update(
          community_id: community_id,
          transaction_type_id: 9999,
          opts: {
            units: [{type: :day}]})

        expect(update_res.success).to eql(false)
      end
    end
  end
end
