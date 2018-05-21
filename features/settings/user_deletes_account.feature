Feature: User deletes account

  @javascript
  Scenario: Only admin cannot delete acccount
    Given there are following users:
      | person |
      | kassi_testperson1 |
    And I am logged in as "kassi_testperson1"
    When I open user menu
    When I follow "Settings"
    And I follow "Account" within ".left-navi"
    Then I should see "Your account can't be deleted because you are the only administrator of the marketplace."

  @javascript
  Scenario: Only admin of the marketplace cannot delete acccount
    Given there are following users:
      | person |
      | kassi_testperson1 |
      | kassi_testperson2 |
    And I am logged in as "kassi_testperson2"
    When I open user menu
    When I follow "Settings"
    And I follow "Account" within ".left-navi"
    And I will confirm all following confirmation dialogs in this page if I am running PhantomJS
    And I press "Permanently delete my account"
    Then I should see "Your account is now deleted."

  @javascript
  Scenario: Stripe account with non zero balance prohibit to delete acccount
    Given there are following users:
      | person |
      | kassi_testperson1 |
      | kassi_testperson2 |
    Given community "test" has payment method "stripe" provisioned
    Given community "test" has payment method "stripe" enabled by admin
    Given I have confirmed stripe account as "kassi_testperson2"
    Given Stripe API refuse to delete the account
    And I am logged in as "kassi_testperson2"
    And I am on the account settings page
    And I will confirm all following confirmation dialogs in this page if I am running PhantomJS
    And I press "Permanently delete my account"
    Then I should see "You account balance is not 0 so it cannot be deleted."

