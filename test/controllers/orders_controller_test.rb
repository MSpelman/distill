require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  setup do
  end

  test "should get index with user's orders" do
    create_two_orders_with_different_users
    login_as(:user)
    get :index
    assert_response :success
    assert_template "index"
    assert_not_nil assigns(:orders)
    assert_equal users(:user).orders.count, assigns(:orders).count
  end

  test "should get index with all orders" do
    create_two_orders_with_different_users
    login_as(:admin)
    get :index
    assert_response :success
    assert_template "index"
    assert_not_nil assigns(:orders)
    assert_equal Order.all.count, assigns(:orders).count
  end

  test "should not get index" do
    create_two_orders_with_different_users
    get :index
    assert_response :redirect
  end

  test "should get new" do
    create_shopping_cart
    get :new
    assert_response :success
    assert_template "new"
    assert_equal Date.today, assigns(:order).earliest_pickup_date
  end

  test "should create order" do
    login_as(:user)
    create_shopping_cart
    original_quantity = products(:whiskey).quantity_in_stock
    assert_difference('Order.count') do
      post :create, order: { pickup_date: Date.today }
    end
    assert_equal Date.today, assigns(:order).order_date
    assert_equal 1, assigns(:order).order_status_id
    assert_not_nil assigns(:order).order_products.first
    assert_not_nil assigns(:order).order_products.first.product_id
    assert_not_nil assigns(:order).order_products.first.quantity
    assert_equal original_quantity - 1, Product.find(products(:whiskey).id).quantity_in_stock
    assert (@request.session[:shopping_cart].empty?)
    assert_redirected_to root_path
  end

  test "should ask user to login" do
    create_shopping_cart
    assert_no_difference('Order.count') do
      post :create, order: { pickup_date: Date.today }
    end
    assert !(@request.session[:shopping_cart].empty?)
    assert (@request.session[:checking_out] == true)
    assert_redirected_to login_path
  end

  test "should not create due to all items being out of stock" do
    login_as(:user)
    create_shopping_cart
    products(:whiskey).update_attributes(quantity_in_stock: 0)
    products(:tshirt).update_attributes(quantity_in_stock: 0)
    assert_no_difference('Order.count') do
      post :create, order: { pickup_date: Date.today - 1 }
    end
    assert @request.session[:shopping_cart].empty?
    assert_redirected_to products_path
  end

  test "should not create due to one item being out of stock" do
    login_as(:user)
    create_shopping_cart
    products(:whiskey).update_attributes(quantity_in_stock: 0)
    assert_no_difference('Order.count') do
      post :create, order: { pickup_date: Date.today - 1 }
    end
    assert !(@request.session[:shopping_cart].empty?)
    assert_equal 1, @request.session[:shopping_cart].size
    assert_equal products(:tshirt).id, @request.session[:shopping_cart][0][:product_id]
    assert_redirected_to new_order_path
  end

  test "should not create due to one item not being available in the desired quantity" do
    login_as(:user)
    create_shopping_cart
    products(:tshirt).update_attributes(quantity_in_stock: 1)
    assert_no_difference('Order.count') do
      post :create, order: { pickup_date: Date.today - 1 }
    end
    assert !(@request.session[:shopping_cart].empty?)
    assert_equal 2, @request.session[:shopping_cart].size
    assert_equal products(:tshirt).id, @request.session[:shopping_cart][1][:product_id]
    assert_equal 1, @request.session[:shopping_cart][1][:quantity]
    assert_redirected_to new_order_path
  end

  test "should not create due to pickup date in past" do
    login_as(:user)
    create_shopping_cart
    assert_no_difference('Order.count') do
      post :create, order: { pickup_date: Date.today - 1 }
    end
    assert !(@request.session[:shopping_cart].empty?)
    assert_template 'new'
  end

  test "should not create because of release date" do
    create_shopping_cart_with_future_release_date
    login_as(:user)
    assert_no_difference('Order.count') do
      post :create, order: { pickup_date: Date.today }
    end
    assert !(@request.session[:shopping_cart].empty?)
    assert_template 'new'
  end

  test "should show order" do
    login_as(:user)
    @order = create_order(1)  # New
    get :show, id: @order.to_param
    assert_response :success
    assert_template "show"
    assert_not_nil assigns(:order)
    assert assigns(:order).valid?
  end

  test "should not show order" do
    @order = create_order(1)  # New
    # User not logged in
    assert_raise(NoMethodError) do
      get :show, id: @order.to_param
    end
    # User trying to show a different user's order
    @order.update_attributes(user_id: users(:admin).id)
    login_as(:user)
    assert_raise(ActiveRecord::RecordNotFound) do
      get :show, id: @order.to_param
    end
  end

  test "should get edit" do
    login_as(:admin)
    @order = create_order(1)  # New
    get :edit, id: @order.to_param
    assert_response :success
    assert_template "edit"
  end

  test "should not get edit" do
    @order = create_order(1)  # New
    # User not logged in
    assert_raise(NoMethodError) do
      get :edit, id: @order.to_param
    end
    # User trying to edit a different user's order
    @order.update_attributes(user_id: users(:admin).id)
    login_as(:user)
    assert_raise(ActiveRecord::RecordNotFound) do
      get :edit, id: @order.to_param
    end
    # Cannot edit due to status
    @order.update_attributes(order_status_id: 3)  # Picked-up; no longer editable
    login_as(:admin)
    get :edit, id: @order.to_param
    assert_response :redirect
  end

  test "should update order" do
    login_as(:user)
    @order = create_order(1)  # New
    @order_product = @order.order_products.first
    original_quantity = @order_product.product.quantity_in_stock
    patch :update, id: @order.to_param, :order => {
                                          :pickup_date => (Date.today + 1),
                                          :order_products_attributes => {
                                            '0' => {
                                              :quantity => 2,
                                              :id => @order_product.id
                                            }
                                          }
                                        }
    assert_equal Date.today + 1, assigns(:order).pickup_date
    assert_equal 2, assigns(:order).order_products.first.quantity
    assert_equal original_quantity - 1, assigns(:order).order_products.first.product.quantity_in_stock
    assert_redirected_to orders_path
  end

  test "should update order but desired quantity not available" do
    login_as(:user)
    @order = create_order(1)  # Order has one product (:whiskey) with a quantity of 1
    @order_product = @order.order_products.first
    @order_product.product.update_attributes(quantity_in_stock: 1)  # 1 more available (for a total of 2), but user wants 3
    patch :update, id: @order.to_param, :order => {
                                          :pickup_date => (Date.today + 1),
                                          :order_products_attributes => {
                                            '0' => {
                                              :quantity => 3,
                                              :id => @order_product.id
                                            }
                                          }
                                        }
    assert_equal Date.today + 1, assigns(:order).pickup_date
    assert_equal 2, assigns(:order).order_products.first.quantity
    assert_equal 0, assigns(:order).order_products.first.product.quantity_in_stock
    assert_redirected_to edit_order_path(@order)
  end

  test "should not update order" do
    @order = create_order(1)  # New
    # Not logged in
    assert_raise(NoMethodError) do
      patch :update, id: @order.to_param, order: { pickup_date: Date.today + 1 }
    end
    # User trying to update another user's order
    @order.update_attributes(user_id: users(:admin).id)
    login_as(:user)
    assert_raise(ActiveRecord::RecordNotFound) do
      patch :update, id: @order.to_param, order: { pickup_date: Date.today + 1 }
    end
    # Cannot update due to status
    @order.update_attributes(order_status_id: 3)  # Picked-up; no longer editable
    login_as(:admin)
    patch :update, id: @order.to_param, order: { pickup_date: Date.today + 1 }
    assert_redirected_to login_path
  end

  test "should not update order due to pickup date in past" do
    login_as(:user)
    @order = create_order(1)  # New
    patch :update, id: @order.to_param, order: { pickup_date: (Date.today - 1) }
    assert_template 'edit'
  end

  test "should not update order because of release date" do
    login_as(:user)
    @order = create_order_with_future_release_date(1)  # New
    patch :update, id: @order.to_param, order: { pickup_date: Date.today }
    assert_template 'edit'
  end

  test "should get cancel" do
    login_as(:user)
    @order = create_order(1)  # Order has one product (:whiskey) with a quantity of 1
    original_quantity = products(:whiskey).quantity_in_stock
    get :cancel, id: @order.to_param
    assert_redirected_to orders_path
    assert_equal 4, assigns(:order).order_status_id  # 4 - Canceled
    assert_equal 1, assigns(:order).cancel_reason_id  # 1 - Customer
    assert_equal original_quantity + 1, assigns(:order).order_products.first.product.quantity_in_stock
    login_as(:admin)
    @order = create_order(2)  # Filled
    get :cancel, id: @order.to_param
    assert_redirected_to orders_path
    assert_equal 4, assigns(:order).order_status_id  # 4 - Canceled
    assert_equal 2, assigns(:order).cancel_reason_id  # 2 - Product Not Available
    assert_equal original_quantity + 2, assigns(:order).order_products.first.product.quantity_in_stock
  end

  test "should not get cancel" do
    @order = create_order(1)  # New
    # Not logged in
    assert_raise(NoMethodError) do
      get :cancel, id: @order.to_param
    end
    # User trying to cancel a different user's order
    @order.update_attributes(user_id: users(:admin).id)
    login_as(:user)
    assert_raise(ActiveRecord::RecordNotFound) do
      get :cancel, id: @order.to_param
    end
    # Cannot cancel due to status
    @order.update_attributes(order_status_id: 3)  # Picked-up; no longer editable
    login_as(:admin)
    get :cancel, id: @order.to_param
    assert_redirected_to login_path
  end

  test "should get fill" do
    login_as(:admin)
    @order = create_order(1)  # New
    get :fill, id: @order.to_param
    assert_redirected_to orders_path
    assert_equal 2, assigns(:order).order_status_id  # 2 - Filled
  end

  test "should not get fill" do
    @order = create_order(1)  # New
    # Not logged in
    assert_raise(NoMethodError) do
      get :fill, id: @order.to_param
    end
    # Only admin can use fill action
    login_as(:user)
    get :fill, id: @order.to_param
    assert_redirected_to login_path
    # Cannot fill due to status
    @order.update_attributes(order_status_id: 3)  # Picked-up; no longer fillable
    get :fill, id: @order.to_param
    assert_redirected_to login_path
  end

  test "should get pickup" do
    login_as(:admin)
    @order = create_order(2)  # Filled
    get :pickup, id: @order.to_param
    assert_redirected_to orders_path
    assert_equal 3, assigns(:order).order_status_id  # 3 - Picked-up
    assert_not_nil assigns(:order).amount_due
    assert_not_nil assigns(:order).order_products.first.unit_price
  end

  test "should not get pickup" do
    @order = create_order(2)  # Filled
    # Not logged in
    assert_raise(NoMethodError) do
      get :pickup, id: @order.to_param
    end
    # Only admin can use pickup action
    login_as(:user)
    get :pickup, id: @order.to_param
    assert_redirected_to login_path
    # Cannot fill due to status
    @order.update_attributes(order_status_id: 3)  # Already Picked-up
    get :pickup, id: @order.to_param
    assert_redirected_to login_path
  end

end
