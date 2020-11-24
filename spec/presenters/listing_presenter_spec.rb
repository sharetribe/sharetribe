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
    let(:transaction1) { FactoryGirl.create(:transaction, community: community, listing: listing, current_state: 'paid') }
    let(:transaction2) { FactoryGirl.create(:transaction, community: community, listing: listing, current_state: 'paid') }
    let(:transaction3) { FactoryGirl.create(:transaction, community: community, listing: listing, current_state: 'paid') }
    let(:transaction4) { FactoryGirl.create(:transaction, community: community, listing: listing, current_state: 'rejected') }
    let(:booking1) { FactoryGirl.create(:booking, tx: transaction1, start_time: '2017-11-14 09:00', end_time: '2017-11-14 10:00', per_hour: true) }
    let(:booking2) { FactoryGirl.create(:booking, tx: transaction2, start_time: '2017-11-14 10:00', end_time: '2017-11-14 11:00', per_hour: true) }
    let(:booking3) { FactoryGirl.create(:booking, tx: transaction2, start_time: '2017-11-14 14:00', end_time: '2017-11-14 15:00', per_hour: true) }
    let(:booking4) { FactoryGirl.create(:booking, tx: transaction4, start_time: '2017-11-14 09:00', end_time: '2017-11-14 10:00', per_hour: true) }


    it '#working_hours_blocked_days 2017-11-14 is busy full day.
        2017-11-13, 2017-11-15 no working hours' do
      Timecop.freeze(Time.local(2017, 11, 13)) do
        time_slot1
        time_slot2
        booking1
        booking2
        booking3
        blocked_days = ListingPresenter.new(listing, community, {}, person)
          .availability_per_hour_blocked_dates
        expect(blocked_days.include?(Date.parse('2017-11-13'))).to eq true
        expect(blocked_days.include?(Date.parse('2017-11-14'))).to eq true
        expect(blocked_days.include?(Date.parse('2017-11-15'))).to eq true
      end
    end

    it '#working_hours_blocked_days 2017-11-14 is busy part day.
        2017-11-13, 2017-11-15 no working hours' do
      Timecop.freeze(Time.local(2017, 11, 13)) do
        time_slot1
        time_slot2
        booking1
        booking2
        blocked_days = ListingPresenter.new(listing, community, {}, person)
          .availability_per_hour_blocked_dates
        expect(blocked_days.include?(Date.parse('2017-11-13'))).to eq true
        expect(blocked_days.include?(Date.parse('2017-11-14'))).to eq false
        expect(blocked_days.include?(Date.parse('2017-11-15'))).to eq true
      end
    end

    it '#availability_per_hour_options_for_select_grouped_by_day' do
      Timecop.freeze(Time.local(2017, 11, 13)) do
        time_slot1
        time_slot2
        options = ListingPresenter.new(listing, community, {}, person)
          .availability_per_hour_options_for_select_grouped_by_day
        expect(options["2017-11-14"]).to eq(
          [
            {:value=>"09:00", :name=>" 9:00 am", :slot=>0},
            {:value=>"10:00", :name=>"10:00 am", :slot=>0},
            {:value=>"11:00", :name=>"11:00 am", :slot=>0, :disabled=>true, :slot_end=>true},
            {:value=>"14:00", :name=>" 2:00 pm", :slot=>1},
            {:value=>"15:00", :name=>" 3:00 pm", :slot=>1, :disabled=>true, :slot_end=>true}
          ]
        )
      end
    end

    it '#availability_per_hour_options_for_select_grouped_by_day is busy part day.' do
      Timecop.freeze(Time.local(2017, 11, 13)) do
        time_slot1
        time_slot2
        booking1
        booking2
        options = ListingPresenter.new(listing, community, {}, person)
          .availability_per_hour_options_for_select_grouped_by_day
        expect(options["2017-11-14"]).to eq(
          [
            {:value=>"09:00", :name=>" 9:00 am", :slot=>0, :disabled=>true, :booking_start=>true},
            {:value=>"10:00", :name=>"10:00 am", :slot=>0, :disabled=>true, :booking_start=>true},
            {:value=>"11:00", :name=>"11:00 am", :slot=>0, :disabled=>true, :slot_end=>true},
            {:value=>"14:00", :name=>" 2:00 pm", :slot=>1},
            {:value=>"15:00", :name=>" 3:00 pm", :slot=>1, :disabled=>true, :slot_end=>true}
          ]
        )
      end
    end

    it '#availability_per_hour_options_for_select_grouped_by_day rejected booking does not block.' do
      Timecop.freeze(Time.local(2017, 11, 13)) do
        time_slot1
        time_slot2
        booking4
        options = ListingPresenter.new(listing, community, {}, person)
          .availability_per_hour_options_for_select_grouped_by_day
        expect(options["2017-11-14"]).to eq(
          [
            {:value=>"09:00", :name=>" 9:00 am", :slot=>0},
            {:value=>"10:00", :name=>"10:00 am", :slot=>0},
            {:value=>"11:00", :name=>"11:00 am", :slot=>0, :disabled=>true, :slot_end=>true},
            {:value=>"14:00", :name=>" 2:00 pm", :slot=>1},
            {:value=>"15:00", :name=>" 3:00 pm", :slot=>1, :disabled=>true, :slot_end=>true}
          ]
        )
      end
    end

    it '#working_hours_props listing is old w/o working time slots.
      Listing has 5 default time slots' do
      working_hours_props = ListingPresenter.new(listing, community, {}, person)
        .working_hours_props
      expect(working_hours_props[:listing_just_created]).to eq true
      expect(working_hours_props[:listing]['working_time_slots'].count).to eq 5
    end

    it '#working_hours_props listing with working time slots saved.
      Listing has no default time slots' do
      listing.update_column(:per_hour_ready, true)
      working_hours_props = ListingPresenter.new(listing, community, {}, person)
        .working_hours_props
      expect(working_hours_props[:listing_just_created]).to eq false
      expect(working_hours_props[:listing]['working_time_slots'].count).to eq 0
    end
  end
end
