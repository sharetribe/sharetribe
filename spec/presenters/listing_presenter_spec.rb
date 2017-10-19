require "spec_helper"

RSpec.describe ListingPresenter, type: :presenter do
  let(:community) { FactoryGirl.create(:community) }
  let(:person) do
    person = FactoryGirl.create(:person, community: community, is_admin: true)
    FactoryGirl.create(:community_membership, community: community, person: person, admin: true)
    person
  end
  let(:listing_shape1) { FactoryGirl.create(:listing_shape, community_id: community.id, sort_priority: 0) }
  let(:listing_shape2) { FactoryGirl.create(:listing_shape, community_id: community.id, sort_priority: 1) }
  let(:listing_shape3) { FactoryGirl.create(:listing_shape, community_id: community.id, sort_priority: 2, deleted: true) }
  let(:listing) do
    FactoryGirl.create(:listing, community_id: community.id, listing_shape_id: listing_shape1.id,
                                 author: person)
  end

  context '#shapes' do
    before do
      listing_shape1
      listing_shape2
      listing_shape3
      listing
    end

    it 'contains ordered shapes without deleted' do
      presenter = ListingPresenter.new(listing, community, {}, person)
      shapes = presenter.shapes
      expect(shapes.size).to eq 2
      expect(shapes.first).to eq listing_shape1
      expect(shapes.last).to eq listing_shape2
      expect(shapes.include?(listing_shape3)).to eq false
    end
  end
end
