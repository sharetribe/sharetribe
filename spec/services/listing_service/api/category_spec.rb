require 'spec_helper'

describe ListingService::API::Categories do

  def create_category!(parent_id: nil, sort_priority: 0, name:, listing_shape_ids: [])
    category_opts = {
      parent_id: parent_id,
      sort_priority: sort_priority,
      basename: name,
      translations: [{name: name, locale: "en"}]
    }

    res = listing_api.categories.create(community_id: community_id, opts: category_opts)
    cat_id = res.data[:id]

    # Create association
    listing_shape_ids.each { |lsid|
      # FIXME Do not use Models to initialize test data for API tests!
      CategoryListingShape.create!(category_id: cat_id, listing_shape_id: lsid)
    }

    cat_id
  end

  # FIXME Do not use Models to initialize test data for API tests!
  let(:community) { FactoryGirl.create(:community) }
  let(:community_id) { community.id }

  # Creates category tree:
  #
  # - bikes
  # -- mountain bikes
  # -- city bikes
  # - cars
  #
  let(:cars_id) { create_category!(sort_priority: 10, name: "Cars", listing_shape_ids: [1]) }
  let(:bikes_id) { create_category!(sort_priority: 0, name: "Bikes") }
  let(:mountain_bikes_id) { create_category!(parent_id: bikes_id, sort_priority: 1, name: "Mountain Bikes", listing_shape_ids: [1, 2]) }
  let(:city_bikes_id) { create_category!(parent_id: bikes_id, sort_priority: 2, name: "City Bikes", listing_shape_ids: [2, 3]) }

  let(:listing_api) { ListingService::API::Api }

  describe "#get_all" do
    context "success" do
      it "gets the category tree" do
        expected_tree = [
          {
            id: bikes_id,
            community_id: community_id,
            parent_id: nil,
            sort_priority: 0,
            name: "bikes",
            listing_shape_ids: [],
            translations: [{ locale: "en", name: "Bikes" }],
            children: [
              {
                id: mountain_bikes_id,
                community_id: community_id,
                parent_id: bikes_id,
                sort_priority: 1,
                name: "mountain-bikes",
                listing_shape_ids: [1, 2],
                translations: [{ locale: "en", name: "Mountain Bikes" }],
                children: []
              },
              {
                id: city_bikes_id,
                community_id: community_id,
                parent_id: bikes_id,
                sort_priority: 2,
                name: "city-bikes",
                listing_shape_ids: [2, 3],
                translations: [{ locale: "en", name: "City Bikes" }],
                children: []
              }
            ]
          }, {
            id: cars_id,
            community_id: community_id,
            parent_id: nil,
            sort_priority: 10,
            name: "cars",
            listing_shape_ids: [1],
            translations: [{ locale: "en", name: "Cars" }],
            children: [],
          }
        ]

        res = listing_api.categories.get_all(community_id: community_id)

        expect(res.success).to eq true
        expect(res.data).to eq expected_tree
      end
    end
  end

  describe "#create" do
    it "creates a category" do

      create_opts = {
        sort_priority: 1,
        basename: "City Bikes",
        translations: [{ locale: "en", name: "City Bikes" }]
      }
      res = listing_api.categories.create(community_id: community_id, opts: create_opts)

      expect(res.success).to eq true
      expect(res.data[:id]).to be_a Fixnum

    end
  end
end
