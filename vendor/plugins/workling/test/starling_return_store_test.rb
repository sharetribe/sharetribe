require File.dirname(__FILE__) + '/test_helper'

context "the starling return store" do
  setup do
    # the memoryreturnstore behaves exactly like memcache. 
    MemCache.expects(:new).at_least(0).returns Workling::Return::Store::MemoryReturnStore.new
    Workling::Clients::MemcacheQueueClient.expects(:connection).at_least(0).returns Workling::Return::Store::MemoryReturnStore.new
  end
  
  specify "should be able to store a value with a key, and then retrieve that same value with the same key." do
    store = Workling::Return::Store::StarlingReturnStore.new
    key, value = :gender, :undecided
    store.set(key, value)
    store.get(key).should.equal(value)
  end
  
  specify "should delete values in the store once they have been get()tted." do
    store = Workling::Return::Store::StarlingReturnStore.new
    key, value = :gender, :undecided
    store.set(key, value)
    store.get(key)
    store.get(key).should.equal nil
  end
  
  specify "should return nothing for a key that is not in the store" do
    store = Workling::Return::Store::StarlingReturnStore.new
    store.get(:bollocks).should.equal nil
  end
end