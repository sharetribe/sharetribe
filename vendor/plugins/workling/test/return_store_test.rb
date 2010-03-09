require File.dirname(__FILE__) + '/test_helper'

context "The return store" do
  specify "should set a value on the current store when invoked like this: Workling::Return::Store.set(:key, 'value')" do
    Workling::Return::Store.set(:key, :value)
    Workling::Return::Store.get(:key).should.equal :value
  end
  
  specify "should get a value on the current store when invoked like this: Workling::Return::Store.get(:key)" do
    Workling::Return::Store.set(:key, :value)
    Workling::Return::Store.get(:key).should.equal :value 
  end
  
  specify "should set a value on the current store when invoked like this: Workling.return.set(:key, 'value')" do
    Workling.return.set(:key, :value)
    Workling.return.get(:key).should.equal :value
  end
end