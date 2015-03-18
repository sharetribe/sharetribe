describe ListingService::API::Shapes do

  let(:shapes) { ListingService::API::Api.shapes }
  let(:community_id) { FactoryGirl.create(:community).id }
  let(:transaction_type) {
    # TODO Temporary
    TransactionType.new(community_id: community_id).tap { |tt|
      tt.translations.build(locale: :en, name: "test")
      tt.save!
    }
  }

  describe "#create" do
    it "creates new listing shape" do
      shapes.create(
        community_id: community_id,
        transaction_type_id: transaction_type.id,
        opts: {
          units: [
            {type: :day},
            {type: :custom, translation_key: 'my.custom.units.translation'}
          ]
        }
      )

      res = shapes.get(community_id: community_id, transaction_type_id: transaction_type.id)

      expect(res.success).to eql(true)

      units = res.data[:units]

      expect(units[0][:type]).to eql(:day)
      expect(units[1][:type]).to eql(:custom)
      expect(units[1][:translation_key]).to eql('my.custom.units.translation')
    end
  end
end
