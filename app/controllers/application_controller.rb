class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

  # Returns the currently logged in user or nil
  def current_user
    return if session[:user_id].nil?
    return @current_user unless @current_user.nil?
    User.find(session[:user_id])
  end

  # Make current_user available as a helper
  helper_method :current_user

  # Method to use as a before_action callback for controllers/actions that require
  # the user be logged in
  def user_only
    return true if logged_in?
    access_denied
  end

  # Determines if user logged in
  def logged_in?
    current_user.is_a? User
  end

  # Make logged_in? available as a helper
  helper_method :logged_in?

  # Prevent user from trying to access user specific functionality without logging in
  def access_denied
    redirect_to login_path, notice: t("application.access_denied") and return false  # You must login before using this option
  end

  # Method to use as a before_action callback for controllers/actions that require
  # the user be logged in as an administrator
  def admin_only
    return true if admin_user?
    admin_access_denied
  end

  # Determines if admin user logged in
  def admin_user?
    logged_in? && current_user.admin
  end

  # Make admin_user? available as a helper
  helper_method :admin_user?

  # Prevent non-admin user from trying to access admin functionality
  def admin_access_denied
    redirect_to login_path, notice: t("application.admin_access_denied") and return false  # You must login as an administrator before using this functionality
  end

  # Method to use as a before_action callback for controllers/actions that require
  # the user not be logged in
  def not_logged_in_only
    return true if !(logged_in?)
    access_is_denied
  end

  # Prevent user from trying to use 'not_logged_in_only' functionality when logged in
  def access_is_denied
    redirect_to root_path, notice: t("application.access_is_denied") and return false  # Established users cannot use this option
  end

  # This method should never return false unless someone is trying to hack the url
  def allow_edit
    return true if edit_allowed?
    edit_order_denied
  end

  # Helper to determine if the user should get a link to edit or cancel the order
  def edit_allowed?(order = @order)
    # return false if (order.order_status.nil?)  # This can be removed; needed because of bad data in DEV
    # Admin can edit as long as order is not Picked-up or Canceled
    return true if (admin_user? && (order.order_status_id <= 2))
    # Regular user can only edit if the status is New
    return true if (logged_in? && (order.order_status_id == 1))
    return false
  end

  # Make edit_allowed? available as a helper
  helper_method :edit_allowed?

  # Error message/redirection for the before_action callbacks
  def edit_order_denied
    redirect_to login_path, notice: t('orders.edit_order_denied') and return false  # "You do not have permission to access this feature."
  end

  # This method should never return false unless someone is trying to hack the url
  def allow_fill
    return true if fill_allowed?
    edit_order_denied
  end

  # Helper to determine if the user should get a link to mark the order as filled
  def fill_allowed?(order = @order)
    # return false if (order.order_status.nil?)  # This can be removed; needed because of bad data in DEV
    # Only Admin can edit, status must be New
    return true if (admin_user? && (order.order_status_id == 1))
    return false
  end

  # Make fill_allowed? available as a helper
  helper_method :fill_allowed?

  # This method should never return false unless someone is trying to hack the url
  def allow_pickup
    return true if pickup_allowed?
    edit_order_denied
  end

  # Helper to determine if the user should get a link to mark the order as picked-up
  def pickup_allowed?(order = @order)
    # return false if (order.order_status.nil?)  # This can be removed; needed because of bad data in DEV
    # Only Admin can edit, status must be Filled
    return true if (admin_user? && (order.order_status_id == 2))
    return false
  end

  # Make pickup_allowed? available as a helper
  helper_method :pickup_allowed?

  # Method to use as a before_action callback for controllers/actions that determines
  # if the user can enter a new comment
  def allow_new_comment
    return true if new_comment_allowed?
    comment_access_denied
  end

  # Determines if user can add a new comment
  def new_comment_allowed?
    # User needs to be logged in
    return false unless logged_in?
    # User needs to have purchased product to comment on it
    product_found = false
    order_count = current_user.orders.count
    order_index = 0
    until (product_found || (order_index >= order_count))
      order = current_user.orders[order_index]
      order_index += 1
      product_count = order.products.count
      product_index = 0
      until (product_found || (product_index >= product_count))
        product = order.products[product_index]
        product_index += 1
        product_found = true if (product.id == @product.id)
      end
    end
    return false unless product_found
    # User can only comment on product once
    return false unless @product.comments.find_by_user_id(current_user.id).nil?
    # Passed all checks, okay to create new comment
    return true
  end

  # Make new_comment_allowed? available as a helper
  helper_method :new_comment_allowed?

  # Prevent user from trying to use 'allow_*_comment' functionality when they do not
  # have access
  def comment_access_denied
    redirect_to root_path, notice: t('application.no_permission') and return false  # "You do not have permission to access this feature."
  end

  # Method to use as a before_action callback for controllers/actions that determines
  # if the user can edit a comment
  def allow_edit_comment
    return true if edit_comment_allowed?
    comment_access_denied
  end

  # Determines if user can edit comment
  def edit_comment_allowed?(comment = @comment)
    # User needs to be logged in
    return false unless logged_in?
    # User can only edit their own comment
    return false unless (comment.user_id == current_user.id)
    # Passed all checks, okay to edit comment
    return true
  end

  # Make edit_comment_allowed? available as a helper
  helper_method :edit_comment_allowed?

  # Method to use as a before_action callback for controllers/actions that determines
  # if the user can delete a comment
  def allow_delete_comment
    return true if delete_comment_allowed?
    comment_access_denied
  end

  # Determines if user can delete comment
  def delete_comment_allowed?(comment = @comment)
    # Admin user can delete any comment
    return true if admin_user?
    # User needs to be logged in
    return false unless logged_in?
    # User can only delete their own comment
    return false unless (comment.user_id == current_user.id)
    # Passed all checks, okay to edit comment
    return true
  end

  # Make delete_comment_allowed? available as a helper
  helper_method :delete_comment_allowed?

end
