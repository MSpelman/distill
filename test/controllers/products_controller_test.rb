require 'test_helper'

class ProductsControllerTest < ActionController::TestCase
  setup do
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_template "index"
    assert_not_nil assigns(:products)
    assert_equal assigns(:products).count, Product.active_only.count
  end

  test "should only include active products in index for non-admin" do
    login_as(:user)
    get :index
    assert_equal assigns(:products).count, Product.active_only.count
  end

  test "should include all products in index for admin" do
    login_as(:admin)
    get :index
    assert_equal assigns(:products).count, Product.all.count
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

  test "should create product" do
    login_as(:admin)
    test_image_path = Rails.root.join('test', 'images', 'test_product_image.jpg')
    temp_file = Tempfile.new('products_controller_test', binmode: true, encoding: 'ascii-8bit')
    File.open(test_image_path, 'rb') { |file| temp_file.write(file.read) }
    product_image = ActionDispatch::Http::UploadedFile.new(tempfile: temp_file)
    product_image.original_filename = 'test_product_image.jpg'  # temp_file ok up to here
    assert_difference('Product.count') do
      post :create, product: { active: true,
                               description: "Product description",
                               image_file: product_image,
                               name: "Vixen Amber Whiskey",
                               price: 29.99,
                               product_type_id: product_types(:whiskey).id,
                               release_date: 2015-02-01 }
    end
    product_image.close
    temp_file.close!
    assert_redirected_to products_path
    assert File.exist?(Rails.root.join('public', 'images', Rails.env, 'products', assigns(:product).image_file_name))
  end

  test "should not create product" do
    login_as(:user)
    assert_no_difference('Product.count') do
      post :create, product: { active: true,
                               description: "Product description",
                               name: "Vixen Amber Whiskey",
                               price: 29.99,
                               product_type_id: product_types(:whiskey).id,
                               release_date: 2015-02-01 }
    end
    assert_response :redirect
  end

  test "should show product" do
    @product = products(:whiskey)
    get :show, id: @product.to_param
    assert_response :success
    assert_template "show"
    assert_not_nil assigns(:product)
    assert assigns(:product).valid?
  end

  test "should get edit" do
    login_as(:admin)
    @product = products(:whiskey)
    get :edit, id: @product.to_param
    assert_response :success
    assert_template "edit"
  end

  test "should not get edit" do
    login_as(:user)
    @product = products(:whiskey)
    get :edit, id: @product.to_param
    assert_response :redirect
  end

  test "should update product" do
    login_as(:admin)
    @product = products(:whiskey)
    test_image_path = Rails.root.join('test', 'images', 'test_product_image.jpg')
    temp_file = Tempfile.new('products_controller_test', binmode: true, encoding: 'ascii-8bit')
    File.open(test_image_path, 'rb') { |file| temp_file.write(file.read) }
    product_image = ActionDispatch::Http::UploadedFile.new(tempfile: temp_file)
    product_image.original_filename = 'test_product_image.jpg'
    patch :update, id: @product.to_param, product: { price: 34.99,
                                                     image_file: product_image }
    product_image.close
    temp_file.close!
    assert_redirected_to products_path
    assert File.exist?(Rails.root.join('public', 'images', Rails.env, 'products', assigns(:product).image_file_name))
  end

  test "should not update product" do
    login_as(:user)
    @product = products(:whiskey)
    patch :update, id: @product.to_param, product: { price: 34.99 }
    assert_redirected_to login_path
  end

  test "should add to cart" do
    @request.session = {}
    @request.session[:shopping_cart] = []
    @product = products(:whiskey)
    assert_difference('@request.session[:shopping_cart].count') do
      post :add_to_cart, id: @product.to_param
    end
    assert_redirected_to products_path
  end

  test "should remove from cart" do
    @request.session = {}
    create_shopping_cart
    @product = products(:whiskey)
    assert_difference('@request.session[:shopping_cart].count', -1) do
      get :remove_from_cart, index: 0
    end
    assert_redirected_to new_order_path
    @product = products(:tshirt)
    assert_difference('@request.session[:shopping_cart].count', -1) do
      get :remove_from_cart, index: 0
    end
    assert_redirected_to products_path
  end

  test "should delete image" do
    # Login and set @product
    login_as(:admin)
    @product = products(:whiskey)
    product_id = @product.id
    # Add image to product since fixture does not have one
    test_image_path = Rails.root.join('test', 'images', 'test_product_image.jpg')
    temp_file = Tempfile.new('products_controller_test', binmode: true, encoding: 'ascii-8bit')
    File.open(test_image_path, 'rb') { |file| temp_file.write(file.read) }
    product_image = ActionDispatch::Http::UploadedFile.new(tempfile: temp_file)
    product_image.original_filename = 'test_product_image.jpg'
    patch :update, id: @product.to_param, product: { image_file: product_image }
    product_image.close
    temp_file.close!
    # Verify image initially exists
    @product = Product.find(product_id)  # Make sure not using stale object
    file_path = Rails.root.join('public', 'images', Rails.env, 'products', @product.image_file_name)
    assert File.exist?(file_path), 'No initial file'
    # Call the delete_image action
    get :delete_image, id: @product.to_param
    # Verify image deletion worked correctly
    assert_redirected_to edit_product_path(@product)
    assert !(File.exist?(file_path)), 'File not deleted'  # Verify image file deleted
    @product = Product.find(product_id)  # Make sure not using stale object
    assert_nil @product.image_file_name
  end

end
