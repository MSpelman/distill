require 'test_helper'

class ProductTest < ActiveSupport::TestCase

  test "should create product" do
    product = Product.new
    product.name = "White Wolf Whiskey"
    product.price = 19.99
    product.product_type_id = product_types(:whiskey).id
    product.description = "Un-aged white whiskey"
    product.release_date = 2015-01-01
    product.quantity_in_stock = 12
    product.active = true
    assert product.save
  end

  test "should find product" do
    product_id = products(:whiskey).id
    assert_nothing_raised { Product.find(product_id) }
  end

  test "should update product" do
    product = products(:whiskey)
    assert product.update_attributes(:price => 25.99)
  end

  test "should not create product with no name" do
    product = Product.new
    product.product_type_id = product_types(:clothing).id
    product.price = "49.99"
    product.quantity_in_stock = 12
    assert !product.valid?
    assert product.errors[:name].any?
    assert_equal ["can't be blank*"], product.errors[:name]
    assert !product.save
  end

  test "should not create product with no product type" do
    product = Product.new
    product.name = "Spirit of the North Hoodie"
    product.price = "49.99"
    product.quantity_in_stock = 12
    assert !product.valid?
    assert product.errors[:product_type_id].any?
    assert_equal ["can't be blank*"], product.errors[:product_type_id]
    assert !product.save
  end

  test "should not create product with no price" do
    product = Product.new
    product.name = "Spirit of the North Shotglass"
    product.product_type_id = product_types(:glass).id
    product.quantity_in_stock = 12
    assert !product.valid?
    assert product.errors[:price].any?
    assert_equal ["can't be blank*"], product.errors[:price]
    assert !product.save
  end

  test "should not create product with no quantity in stock" do
    product = Product.new
    product.name = "Spirit of the North Shotglass"
    product.product_type_id = product_types(:glass).id
    product.price = "9.99"
    assert !product.valid?
    assert product.errors[:quantity_in_stock].any?
    assert_equal ["can't be blank*"], product.errors[:quantity_in_stock]
    assert !product.save
  end

  test "should not create product if image format wrong" do
    product = Product.new
    product.name = "Bad Image Whiskey"
    product.price = 29.99
    product.product_type_id = product_types(:whiskey).id
    product.description = "Whiskey with an image file in the wrong format"
    product.release_date = 2015-01-01
    product.quantity_in_stock = 12
    product.active = true
    test_image_path = Rails.root.join('test', 'images', 'bad_product_image.png')
    temp_file = Tempfile.new('product_test', binmode: true, encoding: 'ascii-8bit')
    File.open(test_image_path, 'rb') { |file| temp_file.write(file.read) }
    product_image = ActionDispatch::Http::UploadedFile.new(tempfile: temp_file)
    product_image.original_filename = 'bad_product_image.png'
    product.image_file = product_image
    assert !product.valid?
    assert product.errors.any?
    assert_equal :"File Format Error*", product.errors.first[0]
    assert !product.save
    product_image.close
    temp_file.close!
  end

  test "should only return active products with active_only scope" do
    scope_products = Product.active_only
    found_products = Product.where(active: true).load
    assert_equal scope_products.count, found_products.count
  end

end
