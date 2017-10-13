require "spec_helper"

describe AnalyticService::API::Api do
  let(:community) { FactoryGirl.create(:community) }
  let(:person) do
    person = FactoryGirl.create(:person, community: community, is_admin: true)
    FactoryGirl.create(:community_membership, community: community, person: person, admin: true)
    person
  end

  context 'intercom' do
    before do
      APP_CONFIG.admin_intercom_app_id = '123'
      APP_CONFIG.admin_intercom_access_token = 'ABC'
    end

    it '#send_event' do
      expect_any_instance_of(AnalyticService::API::Intercom).to receive(:event)
      AnalyticService::API::Api.send_event(person: person,
                                           community: community,
                                           event_data: {event_name: 'logout'})
    end

    it '#send_incremental_properties' do
      expect_any_instance_of(AnalyticService::API::Intercom).to receive(:update_user_incremental_properties)
      AnalyticService::API::Api.send_incremental_properties(person: person,
                                                            community: community,
                                                            properties: {property: 1})
    end
  end
end

