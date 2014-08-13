# == Schema Information
#
# Table name: cached_ressi_events
#
#  id                :integer          not null, primary key
#  user_id           :string(255)
#  application_id    :string(255)
#  session_id        :string(255)
#  ip_address        :string(255)
#  action            :string(255)
#  parameters        :text
#  return_value      :string(255)
#  headers           :text
#  semantic_event_id :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  test_group_number :integer
#  community_id      :integer
#

require 'spec_helper'

describe CachedRessiEvent do
  @OPTIONS = { :return_value=>"nil",
     :parameters =>
     { :format => "json",
       :action => "show",
       :id => "c_hs6WxWOr3RofaaWPEYjL",
       :controller => "collections",
       :app_id => "cWslSQyIyr3yiraaWPEYjL" }.to_json,
     :application_id=>"cWslSQyIyr3yiraaWPEYjL",
     :action=>"TestsController#testing_ressi_logging",
     :session_id=>"63601",
     :user_id=>"biPssKjrCr3PQyaaWPEYjL",
     :ip_address=>"128.214.20.122",
     :semantic_event_id => "running_cached_ressi_event_spec",
     :test_group_number => 2,
     :headers => {"foo" => "bar"}.to_json }

   it "should be created without errors" do
     event = CachedRessiEvent.new(@OPTIONS)
     event.save!
     CachedRessiEvent.count.should > 0
   end
end
