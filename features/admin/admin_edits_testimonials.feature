@javascript
Feature: Admin edit testimonials

  Background:
    Given there are following users:
      | person |
      | kassi_testperson1 |
      | kassi_testperson2 |
    Given "kassi_testperson1" has admin rights in community "test"
    And I am logged in as "kassi_testperson1"
    And there is a listing with title "Massage" from "kassi_testperson1" with category "Services" and with listing shape "Requesting"
    And the price of that listing is 11.44 USD

  Scenario: Admin see list of testimonials
    And there is paid transaction with testimonials for a listing with title "Massage" starter "kassi_testperson2"
    When I go to the testimonials admin page of community "test"
    When click to author testimonial edit link
    Then I should see "Hi from author" within "#testimonial-form"
    Then I fill in "testimonial[text]" with "What is up?"
    Then I will confirm all following confirmation dialogs in this page if I am running PhantomJS
    Then I press "Save"
    Then I wait for 1 seconds
    Then I should see "What is up?" within "#admin_testimonials"
