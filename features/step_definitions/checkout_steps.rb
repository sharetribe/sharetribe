# encoding: UTF-8

When(/^I pay by bill$/) do
  steps %Q{
    When I click Tilisiirto logo
    Then I should see "Testi Pankki"
    When I follow "tästä takaisin kauppiaan sivustolle"
  }
end
