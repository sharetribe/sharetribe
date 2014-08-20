Feature: Admin manages integrations to paypal

  In order to enable payments and receive comissions
  As an admin
  I want to integrate my service to paypal

  Background:
    Given there are following users:
      | person            | given_name | family_name | email               | membership_created_at     |
      | manager           | matti      | manager     | manager@example.com | 2014-03-01 00:12:35 +0200 |
      | kassi_testperson1 | john       | doe         | test2@example.com   | 2013-03-01 00:12:35 +0200 |
      | kassi_testperson2 | jane       | doe         | test1@example.com   | 2012-03-01 00:00:00 +0200 |
    And I am logged in as "manager"
    And "manager" has admin rights in community "test"
    And current community has basic plan
    And I am on the integrations admin page

  Scenario: Admin adds paypal credentials