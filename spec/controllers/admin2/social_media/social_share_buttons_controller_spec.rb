require 'spec_helper'

describe Admin2::SocialMedia::SocialShareButtonsController, type: :controller do
  let(:community) { FactoryBot.create(:community, enable_social_share_buttons: false, private: false) }

  before(:each) do
    @request.host = "#{community.ident}.lvh.me"
    @request.env[:current_marketplace] = community
    user = create_admin_for(community)
    sign_in_for_spec(user)
  end

  it 'enable social_share_buttons' do
    patch :update_share_buttons, params: { community: { enable_social_share_buttons: true } }
    expect(community.reload.enable_social_share_buttons).to eq(true)
  end

  it 'can not change social_share_buttons if community is private' do
    community.update(private: true)
    patch :update_share_buttons, params: { community: { enable_social_share_buttons: true } }
    expect(community.reload.enable_social_share_buttons).to eq(false)
  end
end
