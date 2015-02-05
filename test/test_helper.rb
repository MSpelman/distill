ENV["RAILS_ENV"] ||= "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  # Logs in as one of the users (e.g. :admin) from the fixture
  def login_as(user)
    @request.session[:user_id] = users(user).id
  end

  # Creates an order with a product for use in testing
  # status - parameter that allows you to specify the order status; defaults to 1
  # multiple - true if you want two products on the order
  def create_order(status = 1, multiple = false)
    order = Order.new
    order.order_status_id = status
    order.pickup_date = Date.today
    order.order_date = Date.today
    order.user_id = users(:user).id
    order_product = order.order_products.new
    order_product.product_id = products(:whiskey).id
    order_product.quantity = 1
    if multiple
      order_product_2 = order.order_products.new
      order_product_2.product_id = products(:tshirt).id
      order_product_2.quantity = 2
    end
    order.save
    return order
  end

  # Creates two orders with a product for use in testing
  def create_two_orders_with_different_users
    order = Order.new
    order.order_status_id = 1
    order.pickup_date = Date.today
    order.order_date = Date.today
    order.user_id = users(:user).id
    order_product = order.order_products.new
    order_product.product_id = products(:whiskey).id
    order_product.quantity = 1
    order.save
    order = Order.new
    order.order_status_id = 1
    order.pickup_date = Date.today
    order.order_date = Date.today
    order.user_id = users(:admin).id
    order_product = order.order_products.new
    order_product.product_id = products(:whiskey).id
    order_product.quantity = 1
    order.save
  end

  # Creates an order with a product with a future release date for use in testing
  # status - parameter that allows you to specify the order status; defaults to 1
  def create_order_with_future_release_date(status = 1)
    order = Order.new
    order.order_status_id = status
    order.pickup_date = '2015-12-31'
    order.order_date = Date.today
    order.user_id = users(:user).id
    order_product = order.order_products.new
    order_product.product_id = products(:future).id
    order_product.quantity = 1
    order.save
    return order
  end

  # Adds products to shopping cart
  def create_shopping_cart
    @request.session[:shopping_cart] = []
    @request.session[:shopping_cart] << { product_id: products(:whiskey).id, quantity: 1}
    @request.session[:shopping_cart] << { product_id: products(:tshirt).id, quantity: 2}
  end

  # Adds product to shopping cart with future release date
  def create_shopping_cart_with_future_release_date
    @request.session[:shopping_cart] = []
    @request.session[:shopping_cart] << { product_id: products(:future).id, quantity: 1 }
    @request.session[:shopping_cart] << { product_id: products(:whiskey).id, quantity: 2 }
  end

  # Creates a comment and order for :whiskey product and :user user
  def create_comment_and_order_for_whiskey_and_user
    create_order(3)  # order placed by users(:user) for products(:whiskey)
    create_comment  # creates comment by users(:user) for products(:whiskey)
  end

  # Creates comment by users(:user) for products(:whiskey)
  def create_comment
    comment = Comment.new
    comment.summary = "Comment Summary"
    comment.detail = "This is the details of the comment."
    comment.rating = 5
    comment.active = true
    comment.product_id = products(:whiskey).id
    comment.user_id = users(:user).id
    comment.save
    return comment
  end

  # Determines if admin user logged in
  def admin_user?
    logged_in? && current_user.admin
  end

  # Determines if user logged in
  def logged_in?
    current_user.is_a? User
  end

  # Returns the currently logged in user or nil
  def current_user
    return if session[:user_id].nil?
    return @current_user unless @current_user.nil?
    User.find(session[:user_id])
  end

  # Helper to determine if the user should get a link to edit or cancel the order
  def edit_allowed?(order = @order)
    #return false if (order.order_status.nil?)  # This can be removed; needed because of bad data in DEV
    # Admin can edit as long as order is not Picked-up or Canceled
    return true if (admin_user? && (order.order_status_id <= 2))
    # Regular user can only edit if the status is New
    return true if (logged_in? && (order.order_status_id == 1))
    return false
  end

  # Helper to determine if the user should get a link to mark the order as filled
  def fill_allowed?(order = @order)
    #return false if (order.order_status.nil?)  # This can be removed; needed because of bad data in DEV
    # Only Admin can edit, status must be New
    return true if (admin_user? && (order.order_status_id == 1))
    return false
  end

  # Helper to determine if the user should get a link to mark the order as picked-up
  def pickup_allowed?(order = @order)
    #return false if (order.order_status.nil?)  # This can be removed; needed because of bad data in DEV
    # Only Admin can edit, status must be Filled
    return true if (admin_user? && (order.order_status_id == 2))
    return false
  end

end
