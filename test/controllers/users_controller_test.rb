require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
  end

  test "should get index" do
    login_as(:admin)
    get :index
    assert_response :success
    assert_template "index"    
    assert_not_nil assigns(:users)
  end

  test "should not get index" do
    login_as(:user)
    get :index
    assert_response :redirect
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

  test "should get new_self" do
    get :new_self
    assert_response :success
    assert_template "new_self"
  end

  test "should not get new_self" do
    login_as(:user)
    get :new_self
    assert_response :redirect
  end

  test "should create user for admin" do
    login_as(:admin)
    assert_difference('User.count') do
      post :create, user: { active: true, 
                            address_1: "address line 1",
                            address_2: "address line 2",
                            admin: false,
                            apt_number: "3B",
                            city: "Milwaukee",
                            email: "create_admin@example.com",
                            password: "c0ntr0!!3r",
                            name: "Create Admin",
                            newsletter: false,
                            state: states(:wi).id,
                            zip_code: "53741" }
    end
    assert_redirected_to search_users_path
  end

  test "should create user for self" do
    assert_difference('User.count') do
      post :create, user: { address_1: "address line 1",
                            address_2: "address line 2",
                            apt_number: "3B",
                            city: "Milwaukee",
                            email: "create_self@example.com",
                            password: "c0ntr0!!3r",
                            name: "Create Self",
                            newsletter: false,
                            state: states(:wi).id,
                            zip_code: "53741" }
    end
    assert_redirected_to root_path
    assert @request.session[:user_id]
  end

  test "should show user" do
    login_as(:admin)
    @user = users(:admin)
    get :show, id: @user.to_param
    assert_response :success
    assert_template "show"
    assert_not_nil assigns(:user)
    assert assigns(:user).valid?
  end

  test "should not show user" do
    login_as(:user)
    @user = users(:admin)
    get :show, id: @user.to_param
    assert_response :redirect
  end

  test "should get edit" do
    login_as(:admin)
    @user = users(:user)
    get :edit, id: @user.to_param
    assert_response :success
    assert_template "edit"
  end

  test "should not get edit" do
    login_as(:user)
    @user = users(:user)
    get :edit, id: @user.to_param
    assert_response :redirect
  end

  test "should get edit_self" do
    login_as(:user)
    @user = users(:user)
    get :edit_self, id: @user.to_param
    assert_response :success
    assert_template "edit_self"
  end

  test "should not get edit_self" do
    @user = users(:user)
    get :edit_self, id: @user.to_param
    assert_response :redirect
  end

  test "should update user for admin" do
    login_as(:admin)
    @user = users(:user)
    patch :update, id: @user.to_param, user: { address_1: "new address line 1" }
    assert_redirected_to search_users_path
  end

  test "should update user for self" do
    login_as(:user)
    @user = users(:user)
    patch :update, id: @user.to_param, user: { address_1: "new new address line 1" }
    assert_redirected_to root_path
  end

  test "should not update user" do
    @user = users(:user)
    patch :update, id: @user.to_param, user: { address_1: "new new address line 1" }
    assert_redirected_to login_path
  end

  test "should get search" do
    login_as(:admin)
    get :search
    assert_response :success
    assert_template "search"    
    assert_not_nil assigns(:users)
    assert_nil @request.session[:showing_user]
  end

  test "should not get search" do
    login_as(:user)
    get :search
    assert_redirected_to login_path
  end

  test "should return search result" do
    login_as(:admin)
    @user = users(:user)
    post :search_result, email: @user.email
    assert_redirected_to @user
    assert_not_nil assigns(:user)
  end

  test "should not return search result" do
    @user = users(:user)
    # Not admin
    login_as(:user)
    post :search_result, email: @user.email
    assert_redirected_to login_path
    # No email specified
    login_as(:admin)
    post :search_result, email: ''
    assert_redirected_to search_users_path
    # Bad email address
    post :search_result, email: 'bad_email@example.com'
    assert_redirected_to search_users_path
  end

end
