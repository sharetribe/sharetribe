require File.dirname(__FILE__) + '/test_helper.rb'

context "the spawn runner" do  
  specify "should invoke work that is delegated to it" do
    old_dispatcher = Workling::Remote.dispatcher
    Workling::Remote.dispatcher = Workling::Remote::Runners::SpawnRunner.new
    Workling::Remote.run(:util, :echo)
    Workling::Remote.dispatcher = old_dispatcher
  end
end