# coding: utf-8
describe ListingService::API::Shapes do

  let(:shapes) { ListingService::API::Api.shapes }
  let(:community_id) { FactoryGirl.create(:community).id }
  let(:transaction_process_id) { 555 }

  describe "#create" do
    it "creates new listing shape" do
      create_shape_res = shapes.create(
        community_id: community_id,
        opts: {
          price_enabled: true,
          transaction_process_id: transaction_process_id,

          # TODO Move these to translation service
          translations: [
            { locale: "en", name: "Selling", action_button_label: "Buy" },
            { locale: "fi", name: "Myydään", action_button_label: "Osta" }
          ],

          units: [
            {type: :day},
            {type: :custom, translation_key: 'my.custom.units.translation'}
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
      expect(shape[:transaction_process_id]).to eql(transaction_process_id)
      expect(shape[:transaction_type_id]).to be_a(Fixnum)

      units = shape[:units]

      expect(units[0][:type]).to eql(:day)
      expect(units[1][:type]).to eql(:custom)
      expect(units[1][:translation_key]).to eql('my.custom.units.translation')
    end
  end
end
