class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :cancel, :fill, :pickup]
  before_action :user_only, only: [:index, :show]  # do not need to be logged in to access new or create; edit, update, cancel, fill, and pickup have other callbacks that validate user
  before_action :allow_edit, only: [:edit, :update, :cancel]
  before_action :allow_fill, only: [:fill]
  before_action :allow_pickup, only: [:pickup]

  # GET /orders
  # GET /orders.json
  def index
    session[:showing_user] = nil  # make sure this session variable is cleared out
    if admin_user?
      @orders = Order.all
    else
      @orders = current_user.orders.to_a
    end
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
  end

  # GET /orders/new
  def new 
      @order = Order.new
      @order.earliest_pickup_date = calculate_earliest_pickup_date(:create)
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders
  # POST /orders.json
  def create
    unless logged_in?
      session[:checking_out] = true
      redirect_to login_path, notice: t('orders.must_log_in')  # "You must log in before placing an order."
    else
      @order = current_user.orders.new(order_params)
      @order.earliest_pickup_date = calculate_earliest_pickup_date(:create)
      respond_to do |format|
        if @order.save
          @order.update_attributes(order_date: Date.today, order_status_id: 1)  # set order date to today, status to New
          session[:shopping_cart].each do |element|  # create an order_product record for each product in the shopping cart
            product = Product.find(element[:product_id])
            quantity = element[:quantity]
            @order.order_products.create(product_id: product.id, quantity: quantity)
          end
          session[:shopping_cart].clear
          format.html { redirect_to root_path, notice: t('orders.create') }  # "Your order was successfully submitted!"
          format.json { render action: 'index', status: :created, location: @order }
        else
          format.html { render action: 'new' }
          format.json { render json: @order.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    @order.earliest_pickup_date = calculate_earliest_pickup_date(:update)
    respond_to do |format|
      if @order.update(order_params)
        if session[:showing_user]
          format.html { redirect_to @order.user, notice: t('orders.create') }  # "Order was successfully updated."
          format.json { head :no_content }
        else
          format.html { redirect_to orders_path, notice: t('orders.create') }  # "Order was successfully updated."
          format.json { head :no_content }
        end
      else
        format.html { render action: 'edit' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /orders/1/cancel
  # Action to cancel an order
  def cancel
    if admin_user?
      cancel_reason_id = 2  # Product Not Available
    else
      cancel_reason_id = 1  # Customer
    end
    respond_to do |format|
      if @order.update_attributes(order_status_id: 4, cancel_reason_id: cancel_reason_id)
        if session[:showing_user]
          format.html { redirect_to @order.user, notice: t('orders.cancel') }  # "Order was successfully canceled."
          format.json { head :no_content }
        else
          format.html { redirect_to orders_path, notice: t('orders.cancel') }  # "Order was successfully canceled."
          format.json { head :no_content }
        end
      else
        if session[:showing_user]
          format.html { redirect_to @order.user, notice: t('orders.cancel_error') }  # "Error canceling order."
          format.json { render json: @order.errors, status: :unprocessable_entity }
        else
          format.html { redirect_to orders_path, notice: t('orders.cancel_error') }  # "Error canceling order."
          format.json { render json: @order.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # GET /orders/1/fill
  # Action to mark an order as filled
  def fill
    respond_to do |format|
      if @order.update_attributes(order_status_id: 2)
        if session[:showing_user]
          format.html { redirect_to @order.user, notice: t('orders.fill') }  # "Order was successfully filled."
          format.json { head :no_content }
        else
          format.html { redirect_to orders_path, notice: t('orders.fill') }  # "Order was successfully filled."
          format.json { head :no_content }
        end
      else
        if session[:showing_user]
          format.html { redirect_to @order.user, notice: t('orders.fill_error') }  # "Error filling order."
          format.json { render json: @order.errors, status: :unprocessable_entity }
        else
          format.html { redirect_to orders_path, notice: t('orders.fill_error') }  # "Error filling order."
          format.json { render json: @order.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # GET /orders/1/pickup
  # Action that indicates the user picked up the order
  def pickup
    respond_to do |format|
      if @order.update_attributes(order_status_id: 3)
        @order.order_products.each { |order_product| order_product.update_attributes(unit_price: order_product.product.price) }  # Save off the price of each product at the time the order was completed
        totals = @order.calculate_totals
        attributes_hash = { product_total: totals[:product_total],
                            tax: totals[:tax],
                            amount_due: totals[:amount_due] }
        @order.update_attributes(attributes_hash)  # save off the order totals as of the time the customer paid
        if session[:showing_user]
          format.html { redirect_to @order.user, notice: t('orders.pickup') }  # "Order was successfully picked up."
          format.json { head :no_content }
        else
          format.html { redirect_to orders_path, notice: t('orders.pickup') }  # "Order was successfully picked up."
          format.json { head :no_content }
        end
      else
        if session[:showing_user]
          format.html { redirect_to @order.user, notice: t('orders.pickup_error') }  # "Error picking up order."
          format.json { render json: @order.errors, status: :unprocessable_entity }
        else
          format.html { redirect_to orders_path, notice: t('orders.pickup_error') }  # "Error picking up order."
          format.json { render json: @order.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  # Orders are canceled, not deleted
  #def destroy
  #  @order.destroy
  #  respond_to do |format|
  #    format.html { redirect_to orders_url }
  #    format.json { head :no_content }
  #  end
  #end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_order
      if admin_user?
        @order = Order.find(params[:id])
      else
        @order = current_user.orders.find(params[:id])
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:order_status_id, :pickup_date, :order_date, :cancel_reason_id, :user_id, order_products_attributes: [:id, :order_id, :product_id, :quantity])
    end

    # Calculates the earliest pickup date the user is allowed to select based on the release dates of the products in the order
    # If all products are released, it returns today
    def calculate_earliest_pickup_date(action)
      earliest_date = Date.today
      case action
        when :create
        session[:shopping_cart].each do |element|
          product = Product.find(element[:product_id])
          earliest_date = product.release_date unless ((product.release_date.nil?)||(product.release_date <= earliest_date))
        end
        when :update
        @order.order_products.each do |order_product|
          product = order_product.product
          earliest_date = product.release_date unless ((product.release_date.nil?)||(product.release_date <= earliest_date))
        end
      end
      return earliest_date
    end

end
