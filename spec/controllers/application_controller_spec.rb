require 'spec_helper'

describe ApplicationController, type: :controller do
  controller do
    # a mock method to be able to call index without route
    def index
      # do nothing as we are testing the filters here only
    end
  end

  describe "handling wrong requests coming to login domain" do
    if APP_CONFIG.login_domain
      controller do
        # a mock method to be able to call index without route
        def index
          # do nothing as we are testing the filters here only
        end
      end

      describe "HTTP_REFERER is blank" do

        it "shows error an page" do
          request.host = "login.lvh.me"
          request.env['HTTP_REFERER'] = request.env['HTTP_ORIGIN'] = ''
          get :index
          expect(response).to render_template("public/501.html")
        end

        it "redirects to aalto community if longer request path (to keep legacy email links working)" do
          request.host = "login.lvh.me"
          request.env['HTTP_REFERER'] = request.env['HTTP_ORIGIN'] = ''
          request.env['REQUEST_PATH'] = '/en/people/s0m3Gu1dr4nd0mn3ss/messages/received/42'
          get :index
          expect(response).to redirect_to("http://aalto.kassi.eu/en/people/s0m3Gu1dr4nd0mn3ss/messages/received/42")
        end

      end

      describe "HTTP_REFERER is known but action is wrong for login domain" do

        it "redirects back to the referer domain and shows error" do
          request.host = "login.lvh.me"
          request.env['HTTP_REFERER'] = 'http://test.lvh.me:9887'
          request.env['HTTP_ORIGIN'] = ''
          get :index
          expect(response).to redirect_to("http://test.lvh.me:9887/en")
          expect(flash[:error].class).to eq(Array)
          expect(flash[:error][0]).to eq("error_with_session")
        end
      end
    end
  end

  describe "#check_auth_token" do
    it "logs person in when auth_token is valid" do
      p1 = FactoryGirl.create(:person)
      t = AuthToken.create!(:person_id => p1.id, :expires_at => 10.minutes.from_now, :token_type => "login")
      get :index, params: { :auth => t.token}
      expect(response.status).to eq(302) #redirection to url withouth token in query string
      expect(assigns("current_user").id).to eq(p1.id)
    end
  end
end
