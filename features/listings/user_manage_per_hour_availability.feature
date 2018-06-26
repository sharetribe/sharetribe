Feature: User creates a new listing
  User able to manage listing time slots

  @javascript
  Scenario: Creating a new item "offering services" successfully
    Given skip this scenario as phantomjs crashes
    Given community "test" has payment method "paypal" provisioned
    Given community "test" has payment method "paypal" enabled by admin
    Given community "test" has a listing shape offering services per hour
    Given I have confirmed paypal account
    Given I am logged in
    And I am on the home page
    When I follow "new-listing-link"
    And I select "Items" from listing type menu
    And I select "Tools" from listing type menu
    And I select "Offering Services" from listing type menu
    Then I should see "per hour" within ".quantity-description"
    And I fill in "listing_title" with "Sledgehammer"
    And I fill in "listing_price" with "20"
    And I fill in "listing_description" with "My description"
    And I press "Post listing"
    Then I should see "Sledgehammer"
    Then I should see selected "9:00 am" in the "listing[working_time_slots_attributes][100][from]" dropdown
    Then I should see selected "5:00 pm" in the "listing[working_time_slots_attributes][100][till]" dropdown
    Then I should see selected "9:00 am" in the "listing[working_time_slots_attributes][200][from]" dropdown
    Then I should see selected "5:00 pm" in the "listing[working_time_slots_attributes][200][till]" dropdown
    Then I should see selected "9:00 am" in the "listing[working_time_slots_attributes][300][from]" dropdown
    Then I should see selected "5:00 pm" in the "listing[working_time_slots_attributes][300][till]" dropdown
    Then I should see selected "9:00 am" in the "listing[working_time_slots_attributes][400][from]" dropdown
    Then I should see selected "5:00 pm" in the "listing[working_time_slots_attributes][400][till]" dropdown
    Then I should see selected "9:00 am" in the "listing[working_time_slots_attributes][500][from]" dropdown
    Then I should see selected "5:00 pm" in the "listing[working_time_slots_attributes][500][till]" dropdown
    Then I should see working hours form with changes
    When I press "Save"
    Then I should see working hours form without changes
    Then I should see working hours save button finished
    When I check "enable-sun"
    When I add new working hours time slot for day "sun"
    Then I should see working hours form with changes
    When I press "Save"
    Then I should see working hours form without changes
    Then I should see working hours save button finished

