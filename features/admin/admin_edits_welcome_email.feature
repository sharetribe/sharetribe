Feature: Admin edits welcome
  In order to have custom welcome email content tailored specifically for my community
  As an admin
  I want to be able to edit the welcome email content

  @javascript
  Scenario: Admin user can edit community details
    Given I am logged in as "kassi_testperson1"
    When I go to the admin view of community "test"
    And I follow "Emails"
    Then I should not have editor open
    When I follow "Edit message"
    Then I should have editor open
    When I send keys "This is a new line to welcome email" to editor
    And I click save on the editor
    Then I should see "This is a new line to welcome email"
    When I refresh the page
    Then I should see "This is a new line to welcome email"
    When I follow "Send test message"
    And the system processes jobs
    Then "kassi_testperson1@example.com" should receive an email
    When I open the email
    Then I should see "This is a new line to welcome email" in the email body

  @javascript
  Scenario: Admin user can change sender email
    Given I am logged in as "kassi_testperson1"
    When I go to the admin view of community "test"
    And I follow the first "Emails"
    And I fill in "name" with "Not Kassi Tester"
    And I fill in "email" with "not_kassi_testperson1@example.com"
    And I press "Send verification email"
    Then I should see "Sender address: Not Kassi Tester <not_kassi_testperson1@example.com>"
    And I should see "Verified - in use"
    When I follow "change sender email"
    And I fill in "name" with "Another Kassi Tester"
    And I fill in "email" with "another_kassi_testperson1@example.com"
    And I press "Send verification email"
    Then I should see "Sender address: Another Kassi Tester <another_kassi_testperson1@example.com>"
