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
      body = JSON.parse(response.body)
      expect(body).to eq({
        "id" => 2,
        "title" => "Sledgehammer",
        "working_time_slots" => [{"id"=>nil, "week_day"=>"mon", "from"=>"18:00", "till"=>"17:00", "errors"=>{"from"=>["From must be less than till"], "till"=>["From must be less than till"]}}],
      })
    end
  end
end
