Feature: User browses offered rides
  In order to get from place A to B a cheap and environmentally friendly way
  As a carless Sharetribe-user
  I want to check if someone is offering ridesharing in Sharetribe for the same route that I'm going to take
  
  # Commented out as requires sphinx and that caused some problems in test
  # that we didn't fix now as we might soon change the search engine
  # @javascript
  # Scenario: Browsing all ridesharing offers
  #   Given there are following users:
  #     | person |
  #     | kassi_testperson1 |
  #     | kassi_testperson2 |
  #   And there is rideshare offer from "tkk" to "kamppi" by "kassi_testperson1"
  #   And there is rideshare offer from "Sydney" to "Melbourne" by "kassi_testperson2"
  #   And there is rideshare request from "Oulu" to "Helsinki" by "kassi_testperson2"
  #   And there is item offer with title "axe" from "kassi_testperson1" and with share type "lend"
  #   And I am on the home page
  #   When I select "Rideshare" from "listing_category"
  #   And I select "Offer" from "share_type"
  #   Then I should see "tkk - kamppi"
  #   And I should see "Sydney - Melbourne"
  #   But I should not see "axe"
  #   And I should not see "Oulu"
  #   And I should not see "Helsinki"