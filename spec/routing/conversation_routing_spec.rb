require "spec_helper"

describe "routing for conversations" do
  
  it "routes /en/kassi_testperson1/messages/25/accept to conversations controller" do
    expect(get("/en/kassi_testperson1/messages/25/accept")).to(
      route_to(
        {
          "action"=>"accept",
         "controller"=>"accept_conversations",
         "locale"=>"en",
         "person_id"=>"kassi_testperson1",
         "id"=>"25"
        }
      )
    )
                   
  end
  
end
