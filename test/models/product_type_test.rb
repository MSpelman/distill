require 'test_helper'

class ProductTypeTest < ActiveSupport::TestCase

  test "should find product type" do
    product_type_id = product_types(:whiskey).id
    assert_nothing_raised { ProductType.find(product_type_id) }
  end

  test "should not create product type with duplicate name" do
    product_type = ProductType.new
    product_type.name = "Whiskey"
    assert !product_type.valid?
    assert product_type.errors[:name].any?
    assert_equal ["has already been taken*"], product_type.errors[:name]
    assert !product_type.save
  end

  test "should not create product type with no name" do
    product_type = ProductType.new
    assert !product_type.valid?
    assert product_type.errors[:name].any?
    assert_equal ["can't be blank*"], product_type.errors[:name]
    assert !product_type.save
  end

end
