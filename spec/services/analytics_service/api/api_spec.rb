require "spec_helper"

describe AnalyticService::API::API do
  let(:community) { FactoryBot.create(:community) }
  let(:person) do
    person = FactoryBot.create(:person, community: community, is_admin: true)
    FactoryBot.create(:community_membership, community: community, person: person, admin: true)
    person
  end

  context 'intercom' do
    before do
      @admin_intercom_app_id_old = APP_CONFIG.admin_intercom_app_id
      @admin_intercom_access_token_old = APP_CONFIG.admin_intercom_access_token
      APP_CONFIG.admin_intercom_app_id = '123'
      APP_CONFIG.admin_intercom_access_token = 'ABC'
    end

    after do
      APP_CONFIG.admin_intercom_app_id = @admin_intercom_app_id_old
      APP_CONFIG.admin_intercom_access_token = @admin_intercom_access_token_old
    end

    it '#send_event' do
      expect_any_instance_of(AnalyticService::API::Intercom).to receive(:event)
      AnalyticService::API::API.send_event(person: person,
                                           community: community,
                                           event_data: {event_name: 'logout'})
    end

    it '#send_incremental_properties' do
      expect_any_instance_of(AnalyticService::API::Intercom).to receive(:update_user_incremental_properties)
      AnalyticService::API::API.send_incremental_properties(person: person,
                                                            community: community,
                                                            properties: {property: 1})
    end
  end
end
