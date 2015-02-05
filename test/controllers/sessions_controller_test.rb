require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  test "should get new" do
    get :new
    assert_response :success
    assert_template "new"
  end

  test "should create session" do
    post :create, :email => "admin@example.com", :password => "c0ntr0!!3r"
    assert_response :redirect
    assert_redirected_to root_path
    assert @request.session[:user_id]
  end

  test "should delete session" do
    login_as(:user)
    delete :destroy
    assert_response :redirect
    assert_redirected_to root_path
    assert_nil @request.session[:user_id]
  end

end
