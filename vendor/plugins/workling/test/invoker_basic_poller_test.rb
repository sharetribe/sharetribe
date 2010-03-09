require File.dirname(__FILE__) + '/test_helper.rb'

context "the invoker 'basic poller'" do
  setup do
    routing = Workling::Routing::ClassAndMethodRouting.new
    @client = Workling::Clients::MemoryQueueClient.new
    @client.connect
    @invoker = Workling::Remote::Invokers::BasicPoller.new(routing, @client.class)
  end
  
  specify "should not explode when listen is called, and stop nicely when stop is called. " do
    connection = mock()
    connection.expects(:active?).at_least_once.returns(true)
    ActiveRecord::Base.expects(:connection).at_least_once.returns(connection)
    
    client = mock()
    client.expects(:retrieve).at_least_once.returns("hi")
    client.expects(:connect).at_least_once.returns(true)
    client.expects(:close).at_least_once.returns(true)
    Workling::Clients::MemoryQueueClient.expects(:new).at_least_once.returns(client)
    
    # Don't take longer than 10 seconds to shut this down. 
    Timeout::timeout(10) do
      listener = Thread.new { @invoker.listen }
      @invoker.stop
      listener.join
    end
  end
end