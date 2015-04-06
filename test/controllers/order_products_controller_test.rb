require 'test_helper'

class OrderProductsControllerTest < ActionController::TestCase
  setup do
  end

  test "should destroy order_product" do
    @order = create_order(1, true)  # New
    @order_product = @order.order_products.first
    product = @order_product.product
    product_id = product.id
    quantity = @order_product.quantity
    original_quantity_in_stock = product.quantity_in_stock
    login_as(:user)
    assert_difference('@order.order_products.count', -1) do
      delete :destroy, order_id: @order.to_param, id: @order_product.to_param
    end
    assert_redirected_to edit_order_path(@order)
    assert_equal 1, @order.order_status_id
    product = Product.find(product_id)  # refresh so no longer stale
    assert_equal((original_quantity_in_stock + quantity), product.quantity_in_stock)
  end

  test "should destroy order_product and cancel order" do
    @order = create_order(1)  # New
    @order_product = @order.order_products.first
    product = @order_product.product
    product_id = product.id
    quantity = @order_product.quantity
    original_quantity_in_stock = product.quantity_in_stock
    login_as(:user)
    assert_difference('@order.order_products.count', -1) do
      delete :destroy, order_id: @order.to_param, id: @order_product.to_param
    end
    assert_redirected_to orders_path
    @order = Order.find(@order.id)
    assert_equal 4, @order.order_status_id
    assert_equal 1, @order.cancel_reason_id
    product = Product.find(product_id)  # refresh so no longer stale
    assert_equal((original_quantity_in_stock + quantity), product.quantity_in_stock)
  end

  test "should not destroy order_product" do
    @order = create_order(1)  # New
    @order_product = @order.order_products.first
    # Fails because not logged in
    assert_raise(NoMethodError) do
      delete :destroy, order_id: @order.to_param, id: @order_product.to_param
    end
    # Fails because wrong order status
    login_as(:user)
    @order.update_attributes(order_status_id: 3)
    assert_no_difference('OrderProduct.count') do
      delete :destroy, order_id: @order.to_param, id: @order_product.to_param
    end
    # Fails because trying to edit a different user's order
    admin_id = users(:admin).id
    @order.update_attributes(user_id: admin_id)
    assert_raise(ActiveRecord::RecordNotFound) do
      delete :destroy, order_id: @order.to_param, id: @order_product.to_param
    end
  end

end
