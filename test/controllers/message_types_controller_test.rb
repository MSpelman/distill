require 'test_helper'

class MessageTypesControllerTest < ActionController::TestCase
  setup do
  end

  test "should get index" do
    login_as(:admin)
    get :index
    assert_response :success
    assert_template "index"
    assert_not_nil assigns(:message_types)
  end

  test "should not get index" do
    login_as(:user)
    get :index
    assert_response :redirect
    assert_nil assigns(:message_types)
  end

  test "should get new" do
    login_as(:admin)
    get :new
    assert_response :success
    assert_template "new"
  end

  test "should not get new" do
    login_as(:user)
    get :new
    assert_response :redirect
  end

  test "should create message_type" do
    login_as(:admin)
    assert_difference('MessageType.count') do
      post :create, message_type: { description: "Test Message Type description",
                                    name: "Test Message Type",
                                    active: true }
    end
    assert_redirected_to message_types_path
  end

  test "should not create message_type" do
    login_as(:user)
    assert_no_difference('MessageType.count') do
      post :create, message_type: { description: "Test Message Type description",
                                    name: "Test Message Type",
                                    active: true }
    end
    assert_response :redirect
  end

  test "should get edit" do
    login_as(:admin)
    @message_type = message_types(:customer_inquiry)
    get :edit, id: @message_type.to_param
    assert_response :success
    assert_template "edit"
  end

  test "should not get edit" do
    login_as(:user)
    @message_type = message_types(:customer_inquiry)
    get :edit, id: @message_type.to_param
    assert_response :redirect
  end

  test "should update message_type" do
    login_as(:admin)
    @message_type = message_types(:customer_inquiry)
    patch :update, id: @message_type.to_param, message_type: { description: "Updated description",
                                                               name: "Updated Name",
                                                               active: false }
    assert_redirected_to message_types_path
    assert_equal "Updated Name", assigns(:message_type).name
  end

  test "should not update message_type" do
    login_as(:user)
    @message_type = message_types(:customer_inquiry)
    patch :update, id: @message_type.to_param, message_type: { description: "Updated description",
                                                               name: "Updated Name",
                                                               active: false }
    assert_redirected_to login_path
  end

end
