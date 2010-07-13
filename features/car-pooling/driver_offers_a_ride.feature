Feature: Driver offers a ride
  In order to help others and/or get some gas money with a car ride I'm going to do anyway
  As a driver planning a car ride soon
  I want to publish my planned route and schedule so that others can ask me to pick them up

    Scenario: Offering car-pooling by SMS
      Given I'm planning to drive somewhere
      When I send SMS "tkk taik 14:00" to Kassi
      Then An offer for car-pooling ride from "tkk" to "taik" starting at "14:00" should be added to Kassi
    
    Scenario: Offering car-pooling from current location by SMS
      Given I'm planning to drive somewhere
      And my phone location can be requested by Kassi
      When I send SMS "hse 9:30" to Kassi
      Then An offer for car-pooling ride from my current location to "hse" starting at "9:30" should be added to Kassi
  
    Scenario: Matching potential passenger is found (phone number)
      Given I have offered a car-pooling ride from "taik" to "tkk" at "13:00"
      And my phone number is in my public profile
      And my phone number is "0501234567"
      And my username is "Simo"
      When a user "Erkki" adds a request to get a ride from "taik" to "tkk" at "13:00"
      Then user "Erkki" should get an SMS "Simo is driving from taik to tkk at 13:00. You can call him at 0501234567"
        
    
    Scenario: Matching potential passenger is found (phone number not public)
      Given I have offered a car-pooling ride from "taik" to "tkk" at "13:00"
      And my phone number is not in my public profile
      When a user "Erkki" adds a request to get a ride from "taik" to "tkk" at "13:00"
      Then I should get an SMS "Erkki needs a ride from taik to tkk. Reply OK to give him your phone number."
      # Is it clever to have additional cofirmation just to release phone number based on some username.. probably not
      # But how should it be done?
    
    
    
    
    
    
