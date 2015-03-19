# coding: utf-8
require 'spec_helper'

describe ListingService::API::Shapes do

  let(:shapes) { ListingService::API::Api.shapes }
  let(:community_id) { FactoryGirl.create(:community).id }
  let(:transaction_process_id) { 555 }

  describe "#create" do
    context "success" do
      it "creates new listing shape with day unit" do
        create_shape_res = shapes.create(
          community_id: community_id,
          opts: {
            price_enabled: true,
            shipping_enabled: true,
            transaction_process_id: transaction_process_id,

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

        res = shapes.get(community_id: community_id, transaction_type_id: transaction_type_id)

        expect(res.success).to eql(true)

        shape = res.data

        expect(shape[:community_id]).to eql(community_id)
        expect(shape[:price_enabled]).to eql(true)
        expect(shape[:shipping_enabled]).to eql(true)
        expect(shape[:transaction_process_id]).to eql(transaction_process_id)
        expect(shape[:transaction_type_id]).to be_a(Fixnum)

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
      end

      it "creates new listing shape with piece unit" do
        create_shape_res = shapes.create(
          community_id: community_id,
          opts: {
            price_enabled: true,
            transaction_process_id: transaction_process_id,
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

        res = shapes.get(community_id: community_id, transaction_type_id: transaction_type_id)

        expect(res.success).to eql(true)

        shape = res.data

        expect(shape[:community_id]).to eql(community_id)
        expect(shape[:price_enabled]).to eql(true)
        expect(shape[:shipping_enabled]).to eql(true)
        expect(shape[:transaction_process_id]).to eql(transaction_process_id)
        expect(shape[:transaction_type_id]).to be_a(Fixnum)

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
      end
    end

    context "failure" do
      it "does not let user to create new listing shape without price but with units" do
        shape_opts = {
          community_id: community_id,
          opts: {
            price_enabled: false,
            transaction_process_id: transaction_process_id,

            # TODO Move these to translation service
            translations: [
              { locale: "en", name: "Selling", action_button_label: "Buy" },
              { locale: "fi", name: "Myydään", action_button_label: "Osta" }
            ],

            units: [
              {type: :piece}
            ]
          }
        }

        expect { shapes.create(shape_opts) }.to raise_error(ArgumentError)
      end

      it "does not let user to create new listing shape with price but without units" do
        shape_opts = {
          community_id: community_id,
          opts: {
            price_enabled: true,
            transaction_process_id: transaction_process_id,

            # TODO Move these to translation service
            translations: [
              { locale: "en", name: "Selling", action_button_label: "Buy" },
              { locale: "fi", name: "Myydään", action_button_label: "Osta" }
            ]
          }
        }

        expect { shapes.create(shape_opts) }.to raise_error(ArgumentError)
      end
    end
  end
end
