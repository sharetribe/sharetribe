require 'spec_helper'

describe CommunitiesController do

  def mock_community(stubs={})
    @mock_community ||= mock_model(Community, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all communities as @communities" do
      Community.stub(:all) { [mock_community] }
      get :index
      assigns(:communities).should eq([mock_community])
    end
  end

  describe "GET show" do
    it "assigns the requested community as @community" do
      Community.stub(:find).with("37") { mock_community }
      get :show, :id => "37"
      assigns(:community).should be(mock_community)
    end
  end

  describe "GET new" do
    it "assigns a new community as @community" do
      Community.stub(:new) { mock_community }
      get :new
      assigns(:community).should be(mock_community)
    end
  end

  describe "GET edit" do
    it "assigns the requested community as @community" do
      Community.stub(:find).with("37") { mock_community }
      get :edit, :id => "37"
      assigns(:community).should be(mock_community)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created community as @community" do
        Community.stub(:new).with({'these' => 'params'}) { mock_community(:save => true) }
        post :create, :community => {'these' => 'params'}
        assigns(:community).should be(mock_community)
      end

      it "redirects to the created community" do
        Community.stub(:new) { mock_community(:save => true) }
        post :create, :community => {}
        response.should redirect_to(community_url(mock_community))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved community as @community" do
        Community.stub(:new).with({'these' => 'params'}) { mock_community(:save => false) }
        post :create, :community => {'these' => 'params'}
        assigns(:community).should be(mock_community)
      end

      it "re-renders the 'new' template" do
        Community.stub(:new) { mock_community(:save => false) }
        post :create, :community => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested community" do
        Community.should_receive(:find).with("37") { mock_community }
        mock_community.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :community => {'these' => 'params'}
      end

      it "assigns the requested community as @community" do
        Community.stub(:find) { mock_community(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:community).should be(mock_community)
      end

      it "redirects to the community" do
        Community.stub(:find) { mock_community(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(community_url(mock_community))
      end
    end

    describe "with invalid params" do
      it "assigns the community as @community" do
        Community.stub(:find) { mock_community(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:community).should be(mock_community)
      end

      it "re-renders the 'edit' template" do
        Community.stub(:find) { mock_community(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested community" do
      Community.should_receive(:find).with("37") { mock_community }
      mock_community.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the communities list" do
      Community.stub(:find) { mock_community }
      delete :destroy, :id => "1"
      response.should redirect_to(communities_url)
    end
  end

end
