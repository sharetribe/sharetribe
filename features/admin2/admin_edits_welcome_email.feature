Feature: Admin edits welcome email

  @javascript
  Scenario: Admin user can edit community details
    Given I am logged in as "kassi_testperson1"
    When I go to the admin2 welcome email community "test"
    And I follow "Open in editor"
    And I change the contents of "welcome_email_content" to "Welcome email"
    And I click save on the editor
    When I follow "Send a test email to yourself"
    And I wait for 1 seconds
    And the system processes jobs
    Then "kassi_testperson1@example.com" should receive an email
    When I open the email
    Then I should see "Welcome email" in the email body
