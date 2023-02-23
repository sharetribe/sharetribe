require 'spec_helper'

describe IntApi::ListingsController, type: :controller do
  render_views

  let(:community) { FactoryGirl.create(:community) }
  let(:listing) { FactoryGirl.create(:listing, community_id: community.id) }

  describe "#update_working_time_slots" do
    before(:each) do
      @request.host = "#{community.ident}.lvh.me"
      @request.env[:current_marketplace] = community
      user = create_admin_for(community)
      sign_in_for_spec(user)
    end

    it 'works' do
      expect(listing.working_time_slots.count).to eq 0
      listing_params = {
        listing: {
          working_time_slots_attributes: {
            id: nil, from: '09:00', till: '17:00', week_day: 'mon'
          }
        }
      }
      get :update_working_time_slots, params: {id: listing.id, format: :json}.merge(listing_params)
      listing.reload
      expect(listing.working_time_slots.count).to eq 1
    end

    it 'does not save invalid working time slots
      and returns errors' do
      expect(listing.working_time_slots.count).to eq 0
      listing_params = {
        listing: {
          working_time_slots_attributes: {
            id: nil, from: '18:00', till: '17:00', week_day: 'mon'
          }
        }
      }
      get :update_working_time_slots, params: {id: listing.id, format: :json}.merge(listing_params)
      listing.reload
      expect(listing.working_time_slots.count).to eq 0
      working_time_slot = JSON.parse(response.body)["working_time_slots"].first
      expect(working_time_slot["errors"]).to eq({
                                                  "from" => ["\"Start time\" must be less than \"End time\""], "till"=>["\"Start time\" must be less than \"End time\""]
                                                })
    end
  end

  describe "#update_blocked_dates" do
    let(:blocked_date) do
      FactoryGirl.create(:listing_blocked_date, listing_id: listing.id, blocked_at: '2020-01-01')
    end

    before(:each) do
      @request.host = "#{community.ident}.lvh.me"
      @request.env[:current_marketplace] = community
      user = create_admin_for(community)
      sign_in_for_spec(user)
    end

    it 'works' do
      expect(listing.blocked_dates.count).to eq 0
      listing_params = {
        listing: {
          blocked_dates_attributes: {
            id: nil, blocked_at: '2020-01-01'
          }
        }
      }
      get :update_blocked_dates, params: {id: listing.id, format: :json}.merge(listing_params)
      listing.reload
      expect(listing.blocked_dates.count).to eq 1
    end

    it 'does not save if date already blocked' do
      blocked_date
      expect(listing.blocked_dates.count).to eq 1
      listing_params = {
        listing: {
          blocked_dates_attributes: {
            id: nil, blocked_at: '2020-01-01'
          }
        }
      }
      get :update_blocked_dates, params: {id: listing.id, format: :json}.merge(listing_params)
      listing.reload
      expect(listing.blocked_dates.count).to eq 1
    end
  end

  describe 'authorization' do
    let(:other_community) { FactoryGirl.create(:community) }

    before(:each) do
      @request.host = "#{other_community.ident}.lvh.me"
      @request.env[:current_marketplace] = other_community
      user = create_admin_for(other_community)
      sign_in_for_spec(user)
    end

    it '#update_working_time_slots' do
      expect(listing.working_time_slots.count).to eq 0
      listing_params = {
        listing: {
          working_time_slots_attributes: {
            id: nil, from: '09:00', till: '17:00', week_day: 'mon'
          }
        }
      }
      expect {
        get :update_working_time_slots, params: {id: listing.id, format: :json}.merge(listing_params)
      }.to raise_error(ActiveRecord::RecordNotFound)
      listing.reload
      expect(listing.working_time_slots.count).to eq 0
    end

    it '#update_blocked_dates' do
      expect(listing.blocked_dates.count).to eq 0
      listing_params = {
        listing: {
          blocked_dates_attributes: {
            id: nil, blocked_at: '2020-01-01'
          }
        }
      }
      expect {
        get :update_blocked_dates, params: {id: listing.id, format: :json}.merge(listing_params)
      }.to raise_error(ActiveRecord::RecordNotFound)
      listing.reload
      expect(listing.blocked_dates.count).to eq 0
    end
  end
end
