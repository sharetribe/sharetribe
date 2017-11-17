require "spec_helper"

RSpec.describe ListingPresenter, type: :presenter do
  let(:community) { FactoryGirl.create(:community) }
  let(:person) do
    person = FactoryGirl.create(:person, community: community, is_admin: true)
    FactoryGirl.create(:community_membership, community: community, person: person, admin: true)
    person
  end

  context '#shapes' do
    let(:listing_shape1) { FactoryGirl.create(:listing_shape, community_id: community.id, sort_priority: 0) }
    let(:listing_shape2) { FactoryGirl.create(:listing_shape, community_id: community.id, sort_priority: 1) }
    let(:listing_shape3) { FactoryGirl.create(:listing_shape, community_id: community.id, sort_priority: 2, deleted: true) }
    let(:listing) do
      FactoryGirl.create(:listing, community_id: community.id, listing_shape_id: listing_shape1.id,
                                   author: person)
    end

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

  context 'availability per hour' do
    let(:listing) { FactoryGirl.create(:listing, community_id: community.id, listing_shape_id: 123) }
    let(:time_slot1) { FactoryGirl.create(:listing_working_time_slot, listing: listing, week_day: :tue, from: '09:00', till: '11:00') }
    let(:time_slot2) { FactoryGirl.create(:listing_working_time_slot, listing: listing, week_day: :tue, from: '14:00', till: '15:00') }
    let(:transaction1) { FactoryGirl.create(:transaction, community: community, listing: listing) }
    let(:transaction2) { FactoryGirl.create(:transaction, community: community, listing: listing) }
    let(:transaction3) { FactoryGirl.create(:transaction, community: community, listing: listing) }
    let(:booking1) { FactoryGirl.create(:booking, tx: transaction1, start_time: '2017-11-14 09:00', end_time: '2017-11-14 10:00', per_hour: true) }
    let(:booking2) { FactoryGirl.create(:booking, tx: transaction2, start_time: '2017-11-14 10:00', end_time: '2017-11-14 11:00', per_hour: true) }
    let(:booking3) { FactoryGirl.create(:booking, tx: transaction2, start_time: '2017-11-14 14:00', end_time: '2017-11-14 15:00', per_hour: true) }

    it '#working_hours_blocked_days 2017-11-14 is busy full day.
        2017-11-13, 2017-11-15 no working hours' do
      time_slot1
      time_slot2
      booking1
      booking2
      booking3
      blocked_days = ListingPresenter.new(listing, community, {}, person)
        .availability_per_hour_blocked_dates(
          start_time: Time.zone.parse('2017-11-13'),
          end_time: Time.zone.parse('2017-11-15')
        )
      expect(blocked_days).to eq [Date.parse('2017-11-13'), Date.parse('2017-11-14'), Date.parse('2017-11-15')]
    end

    it '#working_hours_blocked_days 2017-11-14 is busy part day.
        2017-11-13, 2017-11-15 no working hours' do
      time_slot1
      time_slot2
      booking1
      booking2
      blocked_days = ListingPresenter.new(listing, community, {}, person)
        .availability_per_hour_blocked_dates(
          start_time: Time.zone.parse('2017-11-13'),
          end_time: Time.zone.parse('2017-11-15')
        )
      expect(blocked_days).to eq [Date.parse('2017-11-13'), Date.parse('2017-11-15')]
    end

    it '#availability_per_hour_options_for_select_grouped_by_day' do
      time_slot1
      time_slot2
      options = ListingPresenter.new(listing, community, {}, person)
        .availability_per_hour_options_for_select_grouped_by_day(
          start_time: Time.zone.parse('2017-11-13'),
          end_time: Time.zone.parse('2017-11-15')
        )
      expect(options).to eq({
        "2017-11-14"=>[
          {:value=>"09:00", :name=>" 9:00 am"},
          {:value=>"10:00", :name=>"10:00 am"},
          {:value=>"14:00", :name=>" 2:00 pm"}
        ]
      })
    end

    it '#availability_per_hour_options_for_select_grouped_by_day is busy part day.' do
      time_slot1
      time_slot2
      booking1
      booking2
      options = ListingPresenter.new(listing, community, {}, person)
        .availability_per_hour_options_for_select_grouped_by_day(
          start_time: Time.zone.parse('2017-11-13'),
          end_time: Time.zone.parse('2017-11-15')
        )
      expect(options).to eq({
        "2017-11-14"=>[
          {:value=>"09:00", :name=>" 9:00 am", :disabled=>true},
          {:value=>"10:00", :name=>"10:00 am", :disabled=>true},
          {:value=>"14:00", :name=>" 2:00 pm"}
        ]
      })
    end
  end
end
