require "spec_helper"

describe "routing for people" do
  
  before(:each) do
    @community = FactoryGirl.create(:community)
    @protocol_and_host = "http://#{@community.domain}.test.host"
    @person = FactoryGirl.create(:person)
  end
  
  it "routes /:username to people controller" do
    expect(get "/#{@person.username}").to(
      route_to(
        { 
          :controller => "people", 
          :action => "show", 
          :id => @person.username 
        }
      )
    )
  end
  
  it "routes /:username/settings to settings controller" do
    expect(get "/#{@person.username}/settings").to(
      route_to(
        { 
          :controller => "settings", 
          :action => "show", 
          :person_id => @person.username 
        }
      )
    )    
  end
  
  it "routes /en to home page" do
    expect(get "#{@protocol_and_host}/en").to(
      route_to({ 
                 :controller => "homepage",
                 :action => "index",
                 :locale => "en"
               }))
  end
  
  it "routes /pt-BR to home page" do
    expect(get "/pt-BR").to(
      route_to({ 
                 :controller => "homepage",
                 :action => "index",
                 :locale => "pt-BR"
               }))
  end

  it "routes / to home page" do
    expect(get "/").to(
      route_to({ 
                 :controller => "homepage",
                 :action => "index"
               }))
  end
  
  it "routes /login to login" do
    expect(get "/login").to(
      route_to({ 
                 :controller => "sessions",
                 :action => "new"
               }))
  end
  
  it "routes /logout to logout" do
    expect(get "/logout").to(
      route_to({ 
                 :controller => "sessions",
                 :action => "destroy",
                 :method => :delete
               }))
  end

  it "routes /en/login to login" do
    expect(get "/en/login").to(
      route_to({ 
                 :controller => "sessions",
                 :action => "new",
                 :locale => "en"
               }))
  end
end
