Feature: Canceling an accepted transaction
  In order to cancel a mistakenly accepted transaction
  As a user
  I want to be able to ask for cancelation of a transaction
  
  @pending
  Scenario: other party asks for cancelation
    Given 2 users have a transaction together
    When other one selects "cancel transaction"
    Then the other user should receive a request to cancel the transaction
  
  @pending  
  Scenario: a cancel request is accepted
    Given user has received a cancel request for transaction
    When user accepts the request
    Then the transaction should be deleted
  
  @pending  
  Scenario: a cancel request is rejected
    Given user has received a cancel request for transaction
    When user rejects the request
    Then the transaction should not be deleted
  
  
  
  
  
  
  
  
