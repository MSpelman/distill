require 'test_helper'

class OrderStatusTest < ActiveSupport::TestCase

  test "should find order status" do
    order_status_id = order_statuses(:filled).id
    assert_nothing_raised { OrderStatus.find(order_status_id) }
  end

end
