Feature: Community members receive email updates

  Background:
    Given community emails are sent from name "Marketplace" and address "marketplace@example.com"
    And I am logged in as "kassi_testperson1"
    And I have just received community updates email
    And there is a listing with title "Sound of Music"
    Then I should have 0 emails

  Scenario: Community member receives emails updates
    When 1 day have passed
    And community updates get delivered
    Then I should have 1 email
    When I open the email
    Then I should see "Sharetribe update" in the email subject
    And I should see the email delivered from "Marketplace <marketplace@example.com>"

  Scenario: Community member does not receive email updates if community does not send them
    Given this community does not send automatic newsletters
    When 1 day have passed
    And community updates get delivered
    Then I should have 0 emails
