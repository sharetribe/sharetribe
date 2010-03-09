require File.dirname(__FILE__) + '/test_helper.rb'

context "the starling runner" do
  specify "should set up a starling client" do
    Workling::Remote.dispatcher = Workling::Remote::Runners::StarlingRunner.new
    Workling::Remote.dispatcher.client.should.not.equal nil
  end
end