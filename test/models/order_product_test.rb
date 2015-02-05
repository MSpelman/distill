require 'test_helper'

# Most of the OrderProduct model testing is being done with the Order model because 
# OrderProduct is nested within Order and is edited through an order via nested attributes
class OrderProductTest < ActiveSupport::TestCase

  test "should not create order_product with no product" do
    order_product = OrderProduct.new
    order_product.order_id = 1  # The value this is set to does not matter since record should not be created
    order_product.quantity = 1
    assert !order_product.valid?
    assert order_product.errors[:product_id].any?
    assert_equal ["can't be blank*"], order_product.errors[:product_id]
    assert !order_product.save
  end

  test "should not create order_product with no quantity" do
    order_product = OrderProduct.new
    order_product.order_id = 1  # The value this is set to does not matter since record should not be created
    order_product.product_id = products(:tshirt).id
    assert !order_product.valid?
    assert order_product.errors[:quantity].any?
    assert_equal ["can't be blank*"], order_product.errors[:quantity]
    assert !order_product.save
  end

end
