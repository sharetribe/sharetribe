Feature: Visitor unsubscribe from invitaion to join community

  Scenario: Visitor click on link to unsubscribe
    Given community "test" admin sent invitation to "elaine@example.com" code "ABC"
    When I go to the unsubscribe link with code "ABC" from invitation email to join community
    Then I should see "Successfully unsubscribed from invitation emails"

