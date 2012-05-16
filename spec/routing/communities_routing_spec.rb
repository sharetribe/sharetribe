require "spec_helper"

describe CommunitiesController do
  describe "routing" do

        it "recognizes and generates #index" do
      { :get => "/communities" }.should route_to(:controller => "communities", :action => "index")
    end

        it "recognizes and generates #new" do
      { :get => "/communities/new" }.should route_to(:controller => "communities", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/communities/1" }.should route_to(:controller => "communities", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/communities/1/edit" }.should route_to(:controller => "communities", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/communities" }.should route_to(:controller => "communities", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/communities/1" }.should route_to(:controller => "communities", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/communities/1" }.should route_to(:controller => "communities", :action => "destroy", :id => "1")
    end

  end
end
