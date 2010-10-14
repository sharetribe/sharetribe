Feature: Create listing with sms
  In order to add listings to Kassi quickly with basic phone
  As a user
  I want to be able to type the details in the message and send it to Kassi and get is published as listing
  
  @wip
  @pending
  Scenario: Add new rideshare offer via SMS
    Given I have phone number in my profile
    When I send sms "kassi ride tkk taik 14:00"
    And I am on the homepage
    Then I should see "tkk - taik"
  
  
  
  
  
