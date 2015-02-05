class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :add_to_cart]
  before_action :admin_only, only: [:new, :edit, :create, :update] 

  # GET /products
  # GET /products.json
  def index
    if admin_user?
      @products = Product.all  # Admin needs to see all so they can edit inactive records
    else
      @products = Product.active_only  # Only show customers active products
    end
  end

  # GET /products/1
  # GET /products/1.json
  def show
    session[:comments_index] = nil
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to products_path, notice: t('products.create') }  # "Product was successfully created."
        format.json { render action: 'index', status: :created, location: @product }
      else
        format.html { render action: 'new' }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to products_path , notice: t('products.update') }  # "Product was successfully updated."
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /products/1
  # Adds product and its quantity to shopping cart
  def add_to_cart
    session[:shopping_cart] = [] if (session[:shopping_cart].nil?)
    product_hash = { product_id: @product.id, quantity: params[:quantity].to_i }
    session[:shopping_cart] << product_hash
    redirect_to products_path
  end

  # GET /products/remove_from_cart
  # Removes an item from the shopping cart.  If last item removed it redirects the user
  # to the product listing instead of refreshing the list of items in the shopping cart 
  # (since it is now empty)
  def remove_from_cart
    index_to_remove = params[:index].to_i
    session[:shopping_cart].delete_at(index_to_remove)
    if session[:shopping_cart].empty?
      redirect_to products_path
    else
      redirect_to new_order_path
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  # Deleting a product that is associated with an order would cause data corruption
  # Instead admin can mark as inactive
  #def destroy
  #  @product.destroy
  #  respond_to do |format|
  #    format.html { redirect_to products_url }
  #    format.json { head :no_content }
  #  end
  #end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:product_type_id, :name, :price, :release_date, :description, :active)
    end
end
