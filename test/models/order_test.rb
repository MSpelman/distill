require 'test_helper'

class OrderTest < ActiveSupport::TestCase

  # The Order and OrderProduct models are being tested together because OrderProduct is
  # nested within Order and is edited through an order via nested attributes
  test "should create order and order product" do
    order = Order.new
    order.order_status_id = order_statuses(:new).id
    order.pickup_date = Date.today
    order.order_date = Date.today
    order.user_id = users(:user).id
    order_product = order.order_products.new
    order_product.product_id = products(:whiskey).id
    order_product.quantity = 1
    assert order.save
    assert !order_product.id.nil? # Presence of id means order_product record saved too
  end

  test "should find order and order product" do
    order = create_order(1)  # New
    order_id = order.id
    order_product_id = order.order_products.first.id
    assert_nothing_raised { Order.find(order_id) }
    assert_nothing_raised { order.order_products.find(order_product_id) }
  end

  test "should update order and order product" do
    order = create_order(1)  # New
    order.pickup_date = Date.today + 1
    order_id = order.id
    order_product = order.order_products.first
    order_product.quantity = 2
    order_product_id = order_product.id
    assert order.save
    assert order_product.save
    updated_order = Order.find(order_id)
    updated_order_product = updated_order.order_products.find(order_product_id)
    assert_equal Date.today + 1, updated_order.pickup_date
    assert_equal 2, updated_order_product.quantity
  end

  test "should not create order with no pickup date" do
    order = create_order(1)  # New
    order.pickup_date = nil
    assert !order.valid?
    assert order.errors[:pickup_date].any?
    assert_equal ["can't be blank*"], order.errors[:pickup_date]
    assert !order.save
  end

  test "should not create order with past pickup date" do
    order = create_order(1)  # New
    order.pickup_date = Date.today - 1
    assert !order.valid?
    assert order.errors.any?
    assert_equal :"Pickup Date Error*", order.errors.first[0]
    assert !order.save
  end

  test "should not create order with pickup date prior to release date" do
    order = create_order(1)  # New
    order.earliest_pickup_date = Date.today + 1
    assert !order.valid?
    assert order.errors.any?
    assert_equal :"Pickup Date Error*", order.errors.first[0]
    assert !order.save
  end

  test "should only return orders with correct status when using scopes" do
    new_order = create_order(1)  # New
    filled_order = create_order(2)  # Filled
    picked_up_order = create_order(3)  # Picked-up
    canceled_order = create_order(4)  # Canceled
    assert_equal Order.new_orders.count, Order.where(order_status_id: 1).load.count
    assert_equal Order.filled_orders.count, Order.where(order_status_id: 2).load.count
    assert_equal Order.picked_up_orders.count, Order.where(order_status_id: 3).load.count
    assert_equal Order.canceled_orders.count, Order.where(order_status_id: 4).load.count
  end

end
