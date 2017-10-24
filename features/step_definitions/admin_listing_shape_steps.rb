Given(/^community "(.*?)" has order type "(.*?)"$/) do |community, order_type|
  community = Community.where(ident: community).first
  FactoryGirl.create(:listing_shape, community: community,
                                     transaction_process: FactoryGirl.create(:transaction_process),
                                     name: order_type)
end

