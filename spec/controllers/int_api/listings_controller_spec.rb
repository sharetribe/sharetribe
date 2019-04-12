require 'spec_helper'

describe IntApi::ListingsController, type: :controller do
  render_views

  let(:community) { FactoryGirl.create(:community) }
  let(:listing) { FactoryGirl.create(:listing) }

  before(:each) do
    @request.host = "#{community.ident}.lvh.me"
    @request.env[:current_marketplace] = community
    user = create_admin_for(community)
    sign_in_for_spec(user)
  end

  describe "#update_working_time_slots" do
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
end
