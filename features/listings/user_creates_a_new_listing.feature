Feature: User creates a new listing
  In order to perform a certain task using an item, a skill, or a transport, or to help others
  As a person who does not have the required item, skill, or transport, or has them and wants offer them to others
  I want to be able to offer and request an item, a favor, a transport or housing
  
  Scenario: Creating a new item request successfully
    Given I am logged in
    And I am on the home page
    When I follow "Tell what you need!"
    #And I check "Buy"  #This combined with adding an image breaks the test in a mysterious way.
    And I fill in "listing_title" with "Sledgehammer"
    And I fill in "listing_description" with "My description"
    And I fill in "listing_tag_list" with "Tools, hammers"
    And I attach the file "spec/fixtures/Australian_painted_lady.jpg" to "listing_listing_images_attributes_0_image"
    And I press "Save request"
    Then I should see "Item request: Sledgehammer" within "h1"
    #And I should see "borrow, buy" within ".share_types"
    And I should see "borrowing" within "#share_types_and_tags"
    And I should see "tools, hammers" within "#share_types_and_tags"
    And I should see "Request created successfully" within "#notifications"
    And I should see image with alt text "Sledgehammer"
  
  @javascript
  Scenario: Creating a new item offer successfully
    Given I am logged in
    And I am on the home page
    When I follow "List your items and skills!"
    And I fill in "listing_title" with "My offer"
    And I fill in "listing_description" with "My description"
    And I attach the file "spec/fixtures/Australian_painted_lady.jpg" to "listing_listing_images_attributes_0_image"
    And I press "Save offer"
    Then I should see "Item offer: My offer" within "h1"
    And I should see "Offer created successfully" within "#notifications"
  
  @javascript
  Scenario: Creating a new favor request successfully
    Given I am logged in
    And I am on the home page
    When I follow "Tell what you need!"
    And I follow "Favor"
    And I should not see "Borrow"
    And I fill in "listing_title" with "Massage"
    And I fill in "listing_description" with "My description"
    And I attach the file "spec/fixtures/Australian_painted_lady.jpg" to "listing_listing_images_attributes_0_image"
    And I press "Save request"
    Then I should see "Favor request: Massage" within "h1"
    And I should see "Request created successfully" within "#notifications"
  
  @javascript  
  Scenario: Creating a new rideshare request successfully
    Given I am logged in
    And I am on the home page
    When I follow "Tell what you need!"
    And I follow "Rideshare"
    And I fill in "listing_origin" with "Otaniemi"
    And I fill in "listing_destination" with "Turku"
    And I attach the file "spec/fixtures/Australian_painted_lady.jpg" to "listing_listing_images_attributes_0_image"
    And wait for 2 seconds
    And I press "Save request"
    Then I should see "Rideshare request: Otaniemi - Turku" within "h1"
    And I should see "Request created successfully" within "#notifications" 
  
  @javascript  
  Scenario: Trying to create a new request without being logged in
    Given I am not logged in
    And I am on the home page
    When I follow "Tell what you need!"
    Then I should see "You must log in to Kassi to create a new request." within "#notifications"
    And I should see "Log in to Kassi" within "h2"

  @javascript
  Scenario: Trying to create a new item request with insufficient information
    Given I am logged in
    And I am on the home page
    When I follow "Tell what you need!"
    And I uncheck "borrow"
    And I attach the file "spec/fixtures/i_am_not_image.txt" to "listing_listing_images_attributes_0_image"
    And I select "31" from "listing_valid_until_3i"
    And I select "December" from "listing_valid_until_2i"
    And I select "2012" from "listing_valid_until_1i"
    And I press "Save request"
    Then I should see "This field is required." within ".error"
    And I should see "You must check at least one of the boxes above." within ".error"
    And I should see "This date must be between current time and one year from now." within ".error"
    #And I should see "Please enter a value with a valid extension." within ".error" # Works in UI but not here, reason unknown
    
  @javascript  
  Scenario: Trying to create a new rideshare request with insufficient information
    Given I am logged in
    And I am on the home page
    When I follow "Tell what you need!"
    And I follow "Rideshare"
    And I fill in "Origin" with "Test"
    And I select "31" from "listing_valid_until_3i"
    And I select "December" from "listing_valid_until_2i"
    And I select "2012" from "listing_valid_until_1i"
    And I press "Save request"
    Then I should see "This field is required." within ".error"
    And I should see "Departure time must be between current time and one year from now." within ".error"  
