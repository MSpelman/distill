require 'test_helper'

class ProductTypeTest < ActiveSupport::TestCase

  test "should find product type" do
    product_type_id = product_types(:whiskey).id
    assert_nothing_raised { ProductType.find(product_type_id) }
  end

end
