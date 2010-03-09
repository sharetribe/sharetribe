require File.dirname(__FILE__) + '/test_helper.rb'

context "the memory return store" do
  specify "should be able to store a value with a key, and then retrieve that same value with the same key." do
    store = Workling::Return::Store::MemoryReturnStore.new
    key, value = :gender, :undecided
    store.set(key, value)
    store.get(key).should.equal(value)
  end
  
  specify "should delete values in the store once they have been get()tted." do
    store = Workling::Return::Store::MemoryReturnStore.new
    key, value = :gender, :undecided
    store.set(key, value)
    store.get(key)
    store.get(key).should.equal nil
  end
  
  specify "should return nothing for a key that is not in the store" do
    store = Workling::Return::Store::MemoryReturnStore.new
    store.get(:bollocks).should.equal nil
  end
end