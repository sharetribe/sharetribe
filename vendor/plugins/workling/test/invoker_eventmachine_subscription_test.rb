require File.dirname(__FILE__) + '/test_helper.rb'

context "the invoker 'eventmachine subscription'" do
  setup do
    routing = Workling::Routing::ClassAndMethodRouting.new
    @client_class = Workling::Clients::MemoryQueueClient
    @client = @client_class.new
    @client.connect
    @invoker = Workling::Remote::Invokers::EventmachineSubscriber.new(routing, @client_class)
  end
  
  specify "should invoke Util.echo with the arg 'hello' if the string 'hello' is set onto the queue utils__echo" do

    # make sure all new instances point to the same client. that way, state is shared
    Workling::Clients::MemoryQueueClient.expects(:new).at_least_once.returns @client
    Util.any_instance.expects(:echo).once.with({ :message => "hello" })
    
    # Don't take longer than 10 seconds to shut this down. 
    Timeout::timeout(10) do
      listener = Thread.new { @invoker.listen }
      @client.request("utils__echo", { :message => "hello" })
      @invoker.stop
      listener.join
    end
  end
end