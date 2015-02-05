require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  setup do
  end

  test "should get index" do
    create_comment_and_order_for_whiskey_and_user
    login_as(:admin)
    get :index, product_id: '#'
    assert_response :success
    assert_template "index"
    assert_not_nil assigns(:comments)
  end

  test "should not get index" do
    create_comment_and_order_for_whiskey_and_user
    login_as(:user)
    get :index, product_id: '#'
    assert_response :redirect
  end

  test "should get new" do
    create_order(3)  # Creates order for users(:user) for products(:whiskey)
    @product = products(:whiskey)  # Need product since comments nested under products
    login_as(:user)  # Need to login as user who has order for product
    get :new, product_id: @product.to_param
    assert_response :success
    assert_template "new"
  end

  test "should not get new" do
    create_order(3)  # Creates order for users(:user) for products(:whiskey)
    @product = products(:whiskey)  # Need product since comments nested under products
    # Not logged in
    get :new, product_id: @product.to_param
    assert_response :redirect
    # User has not purchased item
    login_as(:admin)  # the test order was made by users(:user), not :admin
    get :new, product_id: @product.to_param
    assert_response :redirect
    # User has already commented on item
    login_as(:user)
    create_comment  # Creates comment by users(:user) for products(:whiskey)
    get :new, product_id: @product.to_param
    assert_response :redirect
  end

  test "should create comment" do
    create_order(3)  # Creates order for users(:user) for products(:whiskey)
    @product = products(:whiskey)  # Need product since comments nested under products
    login_as(:user)  # Need to login as user who has order for product
    assert_difference('@product.comments.count') do
      post :create, product_id: @product.to_param, comment: { rating: 4, detail: "This product is pretty good", summary: "Pretty Good" }
    end
    assert_equal users(:user).id, assigns(:comment).user_id
    assert_redirected_to @product
  end

  test "should not create comment" do
    create_order(3)  # Creates order for users(:user) for products(:whiskey)
    @product = products(:whiskey)  # Need product since comments nested under products
    # Not logged in
    assert_no_difference('Comment.count') do
      post :create, product_id: @product.to_param, comment: { rating: 4, detail: "This product is pretty good", summary: "Pretty Good" }
    end
    assert_redirected_to root_path
    # User has not purchased item
    login_as(:admin)
    assert_no_difference('Comment.count') do
      post :create, product_id: @product.to_param, comment: { rating: 4, detail: "This product is pretty good", summary: "Pretty Good" }
    end
    assert_redirected_to root_path
    # User has already commented on item
    login_as(:user)  # Need to login as user who has order for product
    create_comment  # Creates comment by users(:user) for products(:whiskey)
    assert_no_difference('Comment.count') do
      post :create, product_id: @product.to_param, comment: { rating: 4, detail: "This product is pretty good", summary: "Pretty Good" }
    end
    assert_redirected_to root_path
  end

  test "should show comment" do
    @product = products(:whiskey)  # Need product since comments nested under products
    @comment = create_comment_and_order_for_whiskey_and_user
    get :show, product_id: @product.to_param, id: @comment.to_param
    assert_response :success
    assert_template "show"
    assert_not_nil assigns(:comment)
    assert assigns(:comment).valid?
  end

  test "should get edit" do
    @product = products(:whiskey)  # Need product since comments nested under products
    @comment = create_comment_and_order_for_whiskey_and_user
    login_as(:user)
    get :edit, product_id: @product.to_param, id: @comment.to_param
    assert_response :success
    assert_template "edit"
  end

  test "should not get edit" do
    @product = products(:whiskey)  # Need product since comments nested under products
    @comment = create_comment_and_order_for_whiskey_and_user
    # Not logged in
    get :edit, product_id: @product.to_param, id: @comment.to_param
    assert_redirected_to root_path
    # Trying to edit a different user's comment
    login_as(:admin)
    get :edit, product_id: @product.to_param, id: @comment.to_param
    assert_redirected_to root_path
  end

  test "should update comment" do
    @product = products(:whiskey)  # Need product since comments nested under products
    @comment = create_comment_and_order_for_whiskey_and_user
    comment_id = @comment.id  #
    login_as(:user)
    patch :update, product_id: @product.to_param, id: @comment.to_param, comment: { rating: 2 }
    @comment = @product.comments.find(comment_id)  #
    assert_equal false, @comment.active
    assert_redirected_to @product
  end

  test "should not update comment" do
    @product = products(:whiskey)  # Need product since comments nested under products
    @comment = create_comment_and_order_for_whiskey_and_user
    # Not logged in
    patch :update, product_id: @product.to_param, id: @comment.to_param, comment: { rating: 2 }
    assert_equal true, @comment.active
    assert_redirected_to root_path
    # Trying to edit a different user's comment
    login_as(:admin)
    patch :update, product_id: @product.to_param, id: @comment.to_param, comment: { rating: 2 }
    assert_equal true, @comment.active
    assert_redirected_to root_path
  end

  test "should destroy comment" do
    @product = products(:whiskey)  # Need product since comments nested under products
    @comment = create_comment_and_order_for_whiskey_and_user
    login_as(:user)
    assert_difference('@product.comments.count', -1) do
      delete :destroy, product_id: @product.to_param, id: @comment.to_param
    end
    assert_redirected_to @product
  end

  test "should destroy any comment for admin" do
    @product = products(:whiskey)  # Need product since comments nested under products
    @comment = create_comment_and_order_for_whiskey_and_user
    login_as(:admin)  # comment is owned by users(:user), make sure admin can still delete it
    assert_difference('@product.comments.count', -1) do
      delete :destroy, product_id: @product.to_param, id: @comment.to_param
    end
    assert_redirected_to @product
  end

  test "should not destroy comment" do
    @product = products(:whiskey)  # Need product since comments nested under products
    @comment = create_comment_and_order_for_whiskey_and_user
    # Not logged in
    assert_no_difference('@product.comments.count') do
      delete :destroy, product_id: @product.to_param, id: @comment.to_param
    end
    assert_redirected_to root_path
    # Trying to delete a different user's comment
    @comment.update_attributes(user_id: users(:admin).id)  # Switch user_id so no longer owned by regular user
    login_as(:user)
    assert_no_difference('@product.comments.count') do
      delete :destroy, product_id: @product.to_param, id: @comment.to_param
    end
    assert_redirected_to root_path
  end

  test "should get approve" do
    @product = products(:whiskey)  # Need product since comments nested under products
    @comment = create_comment_and_order_for_whiskey_and_user
    @comment.update_attributes(active: false)
    login_as(:admin)
    get :approve, product_id: @product.to_param, id: @comment.to_param
    assert_redirected_to product_comments_path('#')
    assert_equal true, assigns(:comment).active
  end

  test "should not get approve" do
    @product = products(:whiskey)  # Need product since comments nested under products
    @comment = create_comment_and_order_for_whiskey_and_user
    @comment.update_attributes(active: false)
    login_as(:user)
    get :approve, product_id: @product.to_param, id: @comment.to_param
    assert_redirected_to login_path
    assert_equal false, assigns(:comment).active
  end

end
