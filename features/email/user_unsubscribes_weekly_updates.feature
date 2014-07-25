Feature: User unsubscribes weekly email

  Background:
    Given a logged in user "jane"

  Scenario: User unsubscribes from email link
    Given I have received a weekly updates email
      And I click a link to unsubscribe
     Then I should see that I have successfully unsubscribed
      And I should not receive weekly updates email anymore