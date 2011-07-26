Feature: User creates a new rideshare

  @javascript
  Scenario: Creating a new rideshare item request successfully
    Given I am logged in
    And I am on the home page
    When I follow "Tell what you need!"
    And I follow "Rideshare"
    And wait for 1 seconds
    And I fill in "listing_origin" with "Tampere"
    And I fill in "listing_destination" with "Turku"
    And I select "January" from "listing_valid_until_2i"
    And I select "2012" from "listing_valid_until_1i"
    And wait for 2 seconds
    And I press "Save request"
    Then I should see "Rideshare request: Tampere - Turku" within "h1"
    And I should see "Request created successfully" within "#notifications"

  @javascript
  Scenario: Creating a new rideshare item request with wrong address in destination
    Given I am logged in
    And I am on the home page
    When I follow "Tell what you need!"
    And I follow "Rideshare"
    And wait for 1 seconds
    And I fill in "listing_origin" with "This place should not exist"
    And I fill in "listing_destination" with "Tampere"
    And wait for 2 seconds
    Then I should see "Address not found" within ".error"
    And I press "Save request"
    Then I should see "Address not found" within ".error"

  @javascript
  Scenario: Creating a new rideshare item request with wrong address in destination
    Given I am logged in
    And I am on the home page
    When I follow "Tell what you need!"
    And I follow "Rideshare"
    And wait for 1 seconds
    And I fill in "listing_origin" with "Tampere"
    And I fill in "listing_destination" with "This place should not exist"
    And wait for 2 seconds
    Then I should see "Address not found" within ".error"
    And I press "Save request"
    Then I should see "Address not found" within ".error"

  @javascript
  Scenario: Creating a new rideshare item offer successfully
    Given I am logged in
    And I am on the home page
    When I follow "List your items and skills!"
    And I follow "Rideshare"
    And wait for 1 seconds
    And I fill in "listing_origin" with "Tampere"
    And I fill in "listing_destination" with "Turku"
    And I select "January" from "listing_valid_until_2i"
    And I select "2012" from "listing_valid_until_1i"
    And wait for 2 seconds
    And I press "Save offer"
    Then I should see "Rideshare offer: Tampere - Turku" within "h1"
    And I should see "Offer created successfully" within "#notifications"

  @javascript
  Scenario: Creating a new rideshare item offer with wrong address in destination
    Given I am logged in
    And I am on the home page
    When I follow "List your items and skills!"
    And I follow "Rideshare"
    And wait for 1 seconds
    And I fill in "listing_origin" with "This place should not exist"
    And I fill in "listing_destination" with "Tampere"
    And wait for 2 seconds
    Then I should see "Address not found" within ".error"
    And I press "Save offer"
    Then I should see "Address not found" within ".error"

  @javascript
  Scenario: Creating a new rideshare item offer with wrong address in destination
    Given I am logged in
    And I am on the home page
    When I follow "List your items and skills!"
    And I follow "Rideshare"
    And wait for 1 seconds
    And I fill in "listing_origin" with "Tampere"
    And I fill in "listing_destination" with "This place should not exist"
    And wait for 2 seconds
    Then I should see "Address not found" within ".error"
    And I press "Save offer"
    Then I should see "Address not found" within ".error"

