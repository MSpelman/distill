require 'test_helper'

class IntegratedTestCasesTest < ActionDispatch::IntegrationTest
  fixtures :all

  test "new user creates user profile for themselves and logs out" do
    new_user_session = create_session
    user_hash = { address_1: "address line 1", 
                  address_2: "address line 2",
                  apt_number: "3B",
                  city: "Milwaukee",
                  email: "integrated_create_self@example.com",
                  password: "c0ntr0!!3r",
                  name: "Integrated Create-Self",
                  newsletter: false,
                  state: "WI",
                  zip_code: "53741" }
    new_user_session.creates_new_self(user_hash)
    new_user_session.log_out
  end

  test "admin logs in and creates new admin user and logs out" do
    admin_user_session = create_session
    admin_user_session.log_in('admin@example.com', 'c0ntr0!!3r')
    user_hash = { active: true,
                  address_1: "address line 1", 
                  address_2: "address line 2",
                  admin: true,
                  apt_number: "3B",
                  city: "Milwaukee",
                  email: "integrated_create_admin@example.com",
                  password: "c0ntr0!!3r",
                  name: "Integrated Create-Admin",
                  newsletter: false,
                  state: "WI",
                  zip_code: "53741" }
    admin_user_session.admin_creates_new_user(user_hash)
    admin_user_session.log_out
  end

  test "user logs in to edit own profile then logs out" do
    user_session = create_session
    user_session.log_in('user@example.com', 'c0ntr0!!3r')
    updated_user_hash = { address_1: "new address line 1" }
    user_session.edit_self(updated_user_hash)
    user_session.log_out
  end

  test "inactive user not allowed to log in" do
    inactive_user_session = create_session
    inactive_user_session.inactive_log_in('inactive_user@example.com', 'c0ntr0!!3r')
  end

  test "unlogged in user goes to product index and views product" do
    unlogged_in_user_session = create_session
    unlogged_in_user_session.show_product_from_index
  end

  test "admin user goes to product index, views product, creates new, edits existing" do
    admin_user_session = create_session
    admin_user_session.log_in('admin@example.com', 'c0ntr0!!3r')

    admin_user_session.show_product_from_index

    product_hash = { name: "Ke-wa-har-kess Whiskey",
                     price: 49.99, 
                     product_type_id: product_types(:whiskey).id,
                     description: "120 proof, super-duper whiskey",
                     active: true }
    admin_user_session.create_new_product(product_hash)

    updated_product_hash = { price: 55.99 }
    admin_user_session.update_edited_product(updated_product_hash)

    admin_user_session.log_out
  end

  test "create product, place orders, change price, and validate order totals" do
    # Create user_session and login
    admin_user_session = create_session
    admin_user_session.log_in('admin@example.com', 'c0ntr0!!3r')

    # Create new product
    product_hash = { name: "Ke-wa-har-kess Whiskey",
                     price: 50.00, 
                     product_type_id: product_types(:whiskey).id,
                     description: "120 proof, super-duper whiskey",
                     active: true }
    admin_user_session.create_new_product(product_hash)
    new_product = Product.find_by_name("Ke-wa-har-kess Whiskey")

    # Place order that is completed (i.e. has a status of Picked-up)
    admin_user_session.add_product_to_cart(new_product, 2)
    completed_order = admin_user_session.checkout_cart(Date.today)
    admin_user_session.fill_order(completed_order)
    admin_user_session.pickup_order(completed_order)

    # Place order with a status of New
    admin_user_session.add_product_to_cart(new_product, 2)
    new_order = admin_user_session.checkout_cart(Date.today)

    # Change product price; just updated attribute since this test case is not designed to
    # validate the product update workflow
    new_product.update_attributes(price: 60.00)

    # Validate order totals and order_product prices on completed order
    completed_order = Order.find(completed_order.id)
    totals = completed_order.calculate_totals
    assert_equal 100.00, completed_order.product_total, "Order Attribute"
    assert_equal 100.00, totals[:product_total]
    assert_equal 5.50, completed_order.tax
    assert_equal 5.50, totals[:tax]
    assert_equal 105.50, completed_order.amount_due
    assert_equal 105.50, totals[:amount_due]
    assert_equal 50.00, completed_order.order_products.first.unit_price

    # Validate order totals and order_product prices on new order
    totals = new_order.calculate_totals
    assert_nil new_order.product_total
    assert_equal 120.00, totals[:product_total]
    assert_nil new_order.tax
    assert_equal 6.60, totals[:tax]
    assert_nil new_order.amount_due
    assert_equal 126.60, totals[:amount_due]
    assert_equal nil, new_order.order_products.first.unit_price

    admin_user_session.log_out
  end

  test "Edit, Fill, & Pickup order through users#show; make sure return to users#show" do
    # User logs in and places order
    user = users(:user)
    user_session = create_session
    user_session.log_in(user.email, 'c0ntr0!!3r')
    user_session.add_product_to_cart(products(:tshirt), 1)
    order = user_session.checkout_cart(Date.today)
    user_session.log_out

    # Admin logs in, shows user record, edits order from there, and returns to user record
    admin_user_session = create_session
    admin_user_session.log_in('admin@example.com', 'c0ntr0!!3r')
    admin_user_session.edit_order_through_show_user(user, order)
    admin_user_session.fill_order_through_show_user(user, order)
    admin_user_session.pickup_order_through_show_user(user, order)
    admin_user_session.log_out  
  end

  test "Cancel order through users#show; make sure return to users#show" do
    # User logs in and places order
    user = users(:user)
    user_session = create_session
    user_session.log_in(user.email, 'c0ntr0!!3r')
    user_session.add_product_to_cart(products(:tshirt), 1)
    order = user_session.checkout_cart(Date.today)
    user_session.log_out

    # Admin logs in, shows user record, cancels order from there, and returns to user record
    admin_user_session = create_session
    admin_user_session.log_in('admin@example.com', 'c0ntr0!!3r')
    admin_user_session.cancel_order_through_show_user(user, order)
    admin_user_session.log_out  
  end

  test "check out when not logged in yet" do
    unlogged_in_user_session = create_session
    unlogged_in_user_session.show_product_from_index
    unlogged_in_user_session.add_product_to_cart(products(:whiskey), 1)
    unlogged_in_user_session.unlogged_in_user_checkout(Date.today)
    unlogged_in_user_session.log_out
  end

  test "user creates comment and admin approves" do
    # Create a past order for user so they are allowed to comment
    create_order(3)  # Creates order for users(:user) for products(:whiskey)
    # Record the number of visible comments for product
    initial_comments_count = products(:whiskey).comments.active_only.count
    # User creates comment
    user_session = create_session
    user_session.log_in('user@example.com', 'c0ntr0!!3r')
    user_session.show_product_from_index
    comment_hash = { summary: "This product is good",
                     rating: 4 }
    comment = user_session.add_comment_to_product(comment_hash)
    user_session.log_out
    # Number of visible comments should be the same
    assert_equal initial_comments_count, products(:whiskey).comments.active_only.count
    # Admin approves comment
    admin_user_session = create_session
    admin_user_session.log_in('admin@example.com', 'c0ntr0!!3r')
    admin_user_session.approve_comment_from_index(comment)
    admin_user_session.log_out
    # Number of visible comments increase by one
    assert_equal (initial_comments_count + 1), products(:whiskey).comments.active_only.count
  end

  private

  def create_session
    open_session do |user_session|

      def user_session.log_in(email, password)
        get login_path
        assert_response :success
        assert_template "new"
        post session_path, :email => email, :password => password
        assert_response :redirect
        assert_redirected_to root_path
        follow_redirect!
        assert_response :success
        assert_template "home"
        assert session[:user_id]
      end

      def user_session.inactive_log_in(email, password)
        get login_path
        assert_response :success
        assert_template "new"
        post session_path, :email => email, :password => password
        assert_template "new"
        assert_nil session[:user_id]
      end

      def user_session.log_out
        get logout_path
        assert_response :redirect
        assert_redirected_to root_path
        assert_nil session[:user_id]
        follow_redirect!
        assert_template "home"
      end

      def user_session.creates_new_self(user_hash)
        get users_new_self_path
        assert_response :success
        assert_template "new_self"
        post users_path, :user => user_hash
        assert assigns(:user).valid?
        assert_response :redirect
        assert_redirected_to root_path
        follow_redirect!
        assert_response :success
        assert_template "home"
        assert session[:user_id]
      end

      def user_session.admin_creates_new_user(user_hash)
        get new_user_path
        assert_response :success
        assert_template "new"
        post users_path, :user => user_hash
        assert assigns(:user).valid?
        assert_response :redirect
        assert_redirected_to search_users_path
        follow_redirect!
        assert_response :success
        assert_template "search"
      end

      def user_session.edit_self(updated_user_hash)
        get edit_self_user_path(session[:user_id])
        assert_response :success
        assert_template "edit_self"
        patch user_path, :user => updated_user_hash
        assert_response :redirect
        assert_redirected_to root_path
        follow_redirect!
        assert_response :success
        assert_template "home"
      end

      def user_session.show_product_from_index
        get products_path
        assert_response :success
        assert_template "index"
        get product_path(products(:whiskey))
        assert_response :success
        assert_template "show"
      end

      def user_session.create_new_product(product_hash)
        get new_product_path
        assert_response :success
        assert_template "new"
        post products_path, :product => product_hash
        assert assigns(:product).valid?
        assert_response :redirect
        assert_redirected_to products_path
        follow_redirect!
        assert_response :success
        assert_template "index"
      end

      def user_session.update_edited_product(updated_product_hash)
        get edit_product_path(products(:whiskey))
        assert_response :success
        assert_template "edit"
        patch product_path, :product => updated_product_hash
        assert assigns(:product).valid?
        assert_response :redirect
        assert_redirected_to products_path
        follow_redirect!
        assert_response :success
        assert_template "index"
      end

      def add_product_to_cart(product, quantity)
        session[:shopping_cart] = [] if session[:shopping_cart].nil?
        assert_difference('session[:shopping_cart].count') do
          post product_path(product), quantity: quantity
        end
        assert_redirected_to products_path
      end

      def checkout_cart(pickup_date)
        get new_order_path
        assert_response :success
        assert_template "new"
        post orders_path, order: { pickup_date: pickup_date }
        order = assigns(:order)
        assert order.valid?
        assert_response :redirect
        assert_redirected_to root_path
        follow_redirect!
        # assert_response :success
        assert_template "home"        
        return order
      end

      def fill_order(order)
        get fill_order_path(order)
        assert_redirected_to orders_path
        assert_equal 2, assigns(:order).order_status_id  # 2 - Filled
      end

      def pickup_order(order)
        get pickup_order_path(order)
        assert_redirected_to orders_path
        assert_equal 3, assigns(:order).order_status_id  # 3 - Picked-up
      end

      def edit_order_through_show_user(user, order)
        # Show user
        get user_path(user)
        assert_response :success
        assert_template "show"

        # Edit/Update order
        get edit_order_path(order)
        assert_response :success
        assert_template "edit"
        patch order_path, order: { pickup_date: Date.today + 1 }
        assert_response :redirect
        assert_redirected_to user_path(user)

        # Make sure return to users#show
        follow_redirect!
        # assert_response :success
        assert_template "show"
      end

      def fill_order_through_show_user(user, order)
        # Show user
        get user_path(user)
        assert_response :success
        assert_template "show"

        # Fill order
        get fill_order_path(order)
        assert_redirected_to user_path(user)

        # Make sure return to users#show
        follow_redirect!
        # assert_response :success
        assert_template "show"
      end

      def pickup_order_through_show_user(user, order)
        # Show user
        get user_path(user)
        assert_response :success
        assert_template "show"

        # Pickup order
        get pickup_order_path(order)
        assert_redirected_to user_path(user)

        # Make sure return to users#show
        follow_redirect!
        # assert_response :success
        assert_template "show"
      end

      def cancel_order_through_show_user(user, order)
        # Show user
        get user_path(user)
        assert_response :success
        assert_template "show"

        # Cancel order
        get cancel_order_path(order)
        assert_redirected_to user_path(user)

        # Make sure return to users#show
        follow_redirect!
        # assert_response :success
        assert_template "show"
      end

      def unlogged_in_user_checkout(pickup_date)
        get new_order_path
        assert_response :success
        assert_template "new"
        post orders_path, order: { pickup_date: pickup_date }
        assert (session[:checking_out] == true)
        assert_redirected_to login_path
        follow_redirect!
        assert_response :success
        assert_template "new"
        post session_path, email: users(:user).email, password: 'c0ntr0!!3r'
        assert_response :redirect
        assert_redirected_to new_order_path
        follow_redirect!
        assert_response :success
        assert_template "new"
        assert session[:user_id]
        post orders_path, order: { pickup_date: pickup_date }
        order = assigns(:order)
        assert order.valid?
        assert_response :redirect
        assert_redirected_to root_path
        follow_redirect!
        assert_response :success
        assert_template "home"
      end

      def user_session.add_comment_to_product(comment_hash)
        product = products(:whiskey)
        get new_product_comment_path(product)
        assert_response :success
        assert_template "new"
        post product_comments_path, product: product, :comment => comment_hash
        comment = product.comments.find(assigns(:comment).id)
        assert comment.valid?
        assert_response :redirect
        assert_redirected_to product_path(product)
        follow_redirect!
        assert_response :success
        assert_template "show"
        return comment
      end

      def user_session.approve_comment_from_index(comment)
        get product_comments_path('#')  # GET index
        assert_response :success
        assert_template "index"
        product = products(:whiskey)
        get approve_product_comment_path(product, comment)  # Approve comment
        assert_redirected_to product_comments_path('#')
        assert_template "index"
      end

    end
  end
end
