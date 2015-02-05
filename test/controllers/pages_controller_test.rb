require 'test_helper'

class PagesControllerTest < ActionController::TestCase

  test "should get home" do
    get :home
    assert_response :success
    assert_template "home"
  end

  test "should get about" do
    get :about
    assert_response :success
    assert_template "about"
  end

  test "should get events" do
    get :events
    assert_response :success
    assert_template "events"
  end

  test "should get contact" do
    get :contact
    assert_response :success
    assert_template "contact"
  end

  test "should get whiskey_process" do
    get :whiskey_process
    assert_response :success
    assert_template "whiskey_process"
  end

end
