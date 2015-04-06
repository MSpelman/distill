class OrderProductsController < ApplicationController
  before_action :set_order
  before_action :allow_destroy, only: [:destroy]

  # GET /order_products
  # GET /order_products.json
  #def index
  #  @order_products = @order.order_products.to_a
  #end

  # order_products records are created by adding products to the cart and then checking
  # out (which creates the order and associated order_products)
  # This action should not be used to create an order_product record
  # GET /order_products/new
  #def new
  #  @order_product = OrderProduct.new
  #end

  # GET /order_products/1/edit
  # order_product records/forms are nested under orders and edited
  # through the orders actions
  #def edit
  #  @order_product = @order.order_products.find(params[:id])
  #end

  # POST /order_products
  # POST /order_products.json
  #def create
  #  @order_product = @order.order_products.new(order_product_params)

  #  respond_to do |format|
  #    if @order_product.save
  #      format.html { redirect_to edit_order_path(@order), notice: t('order_products.create') }  # "Product was successfully added to Order."
  #      format.json { render action: 'edit', status: :created, location: @order }
  #    else
  #      format.html { render action: 'new' }
  #      format.json { render json: @order_product.errors, status: :unprocessable_entity }
  #    end
  #  end
  #end

  # PATCH/PUT /order_products/1
  # PATCH/PUT /order_products/1.json
  #def update
  #  @order_product = @order.order_products.find(params[:id])
  #  respond_to do |format|
  #    if @order_product.update(order_product_params)
  #      format.html { redirect_to edit_order_path(@order), notice: t('order_products.update') }  # "Product was successfully updated on Order."
  #      format.json { head :no_content }
  #    else
  #      format.html { render action: 'edit' }
  #      format.json { render json: @order_product.errors, status: :unprocessable_entity }
  #    end
  #  end
  #end

  # DELETE /order_products/1
  # DELETE /order_products/1.json
  def destroy
    @order_product = @order.order_products.find(params[:id])
    product = @order_product.product
    quantity = @order_product.quantity
    @order_product.destroy
    # Update quantity in stock for Product
    new_quantity_in_stock = (product.quantity_in_stock + quantity)
    product.update_attributes(quantity_in_stock: new_quantity_in_stock)
    respond_to do |format|
      if @order.order_products.empty?
        @order.update_attributes(order_status_id: 4, cancel_reason_id: 1)  # Status changed to canceled, cancel reason set to Customer
        if session[:showing_user]
          format.html { redirect_to @order.user, notice: t('order_products.all_products_removed') }  # "All products removed; Order canceled"
          format.json { head :no_content }
        else
          format.html { redirect_to orders_path, notice: t('order_products.all_products_removed') }  # "All products removed; Order canceled"
          format.json { head :no_content }
        end
      else
        format.html { redirect_to edit_order_path(@order) }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      if admin_user?
        @order = Order.find(params[:order_id])
      else
        @order = current_user.orders.find(params[:order_id])
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_product_params
      params.require(:order_product).permit(:order_id, :product_id, :quantity)
    end

    # This method should never return false unless someone is trying to hack the url
    def allow_destroy
      return true if (admin_user? && (@order.order_status_id <= 2))
      return true if (logged_in? && (@order.order_status_id == 1))
      destroy_denied
    end

    # Error message/redirection for the allow_destroy before_action callback
    def destroy_denied
      redirect_to login_path, notice: t('orders.edit_order_denied') and return false  # "You do not have permission to access this feature."
    end

end
