require File.dirname(__FILE__) + '/test_helper.rb'

context "class and method routing" do
  specify "should create a queue called utils:echo for a Util class that subclasses worker and has the method echo" do
    routing = Workling::Routing::ClassAndMethodRouting.new  
    routing['utils__echo'].class.to_s.should.equal "Util"
  end
  
  specify "should create a queue called analytics:invites:sent for an Analytics::Invites class that subclasses worker and has the method sent" do
    routing = Workling::Routing::ClassAndMethodRouting.new
    routing['analytics__invites__sent'].class.to_s.should.equal "Analytics::Invites"
  end
  
  specify "queue_names_routing_class should return all queue names associated with a class" do
    routing = Workling::Routing::ClassAndMethodRouting.new
    routing.queue_names_routing_class(Util).should.include 'utils__echo'
  end
end