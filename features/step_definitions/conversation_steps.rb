Given /^a new message "([^"]*)" from "([^"]*)" about (item|favor|rideshare|housing) (offer|request)$/ do |message, sender, category, listing_type|
  visit login_path(:locale => :en)
  fill_in("username", :with => sender)
  fill_in("password", :with => "testi")
  click_button("Login")
  #click_link(t("link_label_for_#{category}_#{listing_type}"))
  click_link("Offer your help")
  fill_in("Message:", :with => "message")
  #click_button(t("conversations.new.send_#{listing_type}_message"))
  click_button("Send the offer")
  click_link("Logout")
end

