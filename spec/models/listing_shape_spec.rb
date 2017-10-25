require 'spec_helper'

describe ListingShape, type: :model do
  let(:listing_shape) { FactoryGirl.create(:listing_shape) }

  context '#update_with_opts' do
    it 'creates and destroys listing units' do
      opts = {
        units:
        [
          {:unit_type=>"hour", :name=>nil, :kind=>"time", :selector=>nil, :name_tr_key=>nil, :selector_tr_key=>nil, :quantity_selector=>"number"},
          {:unit_type=>"day", :name=>nil, :kind=>"time", :selector=>nil, :name_tr_key=>nil, :selector_tr_key=>nil, :quantity_selector=>"day"}
        ]
      }
      expect(listing_shape.listing_units.count).to eq 0
      listing_shape.update_with_opts(opts)
      units = listing_shape.listing_units
      expect(units.count).to eq 2
      unit_types = units.map(&:unit_type)
      expect(unit_types.include?('hour')).to eq true
      expect(unit_types.include?('day')).to eq true

      opts2 = {
        units:
        [
          {:unit_type=>"day", :name=>nil, :kind=>"time", :selector=>nil, :name_tr_key=>nil, :selector_tr_key=>nil, :quantity_selector=>"day"},
          {:unit_type=>"night", :name=>nil, :kind=>"time", :selector=>nil, :name_tr_key=>nil, :selector_tr_key=>nil, :quantity_selector=>"night"},
          {:unit_type=>"week", :name=>nil, :kind=>"time", :selector=>nil, :name_tr_key=>nil, :selector_tr_key=>nil, :quantity_selector=>"number"}
        ]
      }
      listing_shape.update_with_opts(opts2)
      units = listing_shape.listing_units
      expect(units.count).to eq 3
      unit_types = units.map(&:unit_type)
      expect(unit_types.include?('day')).to eq true
      expect(unit_types.include?('night')).to eq true
      expect(unit_types.include?('week')).to eq true

      opts3 = { units: [] }
      listing_shape.update_with_opts(opts3)
      units = listing_shape.listing_units
      expect(units.count).to eq 0
    end
  end
end
