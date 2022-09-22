Feature: Admin edits logos and color settings

  Background:
    Given "kassi_testperson1" has admin rights in community "test"
    And there is a listing with title "Massage" from "kassi_testperson1" with category "Services" and with listing shape "Requesting"
    And I am logged in as "kassi_testperson1"
    And I go to the admin2 logos and color community "test"

  @javascript
  Scenario: Admin change favicon
    Given community "test" has default browse view "grid"
     When I attach the file "./spec/fixtures/Australian_painted_lady.jpg" to "community_favicon"
      And I press submit
     Then I wait for 1 seconds
      And I refresh the page
      And I should see "Australian_painted_lady.jpg"
