require 'test_helper'

class KassiEventsControllerTest < ActionController::TestCase

  def test_show_index
      submit_with_person :index, {
        :person_id => people(:one).id
      }, nil, nil, :get
      assert_response :success
      assert_template 'index'
      assert_not_nil assigns(:person)
      assert_not_nil assigns(:kassi_events)
  end

end
