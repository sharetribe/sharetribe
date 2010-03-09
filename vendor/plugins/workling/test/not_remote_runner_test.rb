require File.dirname(__FILE__) + '/test_helper'

context "The not remote runner" do  
  specify "should swallow exceptions raised in the workling" do
    old_dispatcher = Workling::Remote.dispatcher
    
    Workling::Remote.dispatcher = Workling::Remote::Runners::NotRemoteRunner.new
    Workling::Remote.run(:util, :faulty)
    Workling::Remote.dispatcher = old_dispatcher # set back to whence we came
  end
end