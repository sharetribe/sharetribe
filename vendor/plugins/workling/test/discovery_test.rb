require File.dirname(__FILE__) + '/test_helper.rb'

context "discovery" do
  specify "should discover the Util workling, since it subclasses Workling::Base and is on the configured Workling load path." do
    discovered = Workling::Discovery.discovered
    discovered.map(&:to_s).should.include "Util"
  end
  
  specify "should not discover non-worker classes" do
    discovered = Workling::Discovery.discovered
    discovered.all? { |clazz| clazz.superclass == Workling::Base }.should.blaming("some discovered classes were not workers").equal true
  end
end