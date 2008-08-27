require 'test_helper'

class PersonTest < ActiveSupport::TestCase

  # Can't test this in unit test at the moment because COS requires login first
  # Creation and other stuff is tested in integration tests
  
  # def test_create_person
  #   p = Person.create({:username => "pentteri", 
  #                     :password => "testi",
  #                     :email => "pentteri@example.com",
  #                     :coin_amount => 3}, "")
  #   assert p.valid?
  # end

end