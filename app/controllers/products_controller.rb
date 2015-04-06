class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :add_to_cart, :delete_image]
  before_action :admin_only, only: [:new, :edit, :create, :update, :delete_image] 

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
        uploaded_file = params[:product][:image_file]
        save_file(uploaded_file) unless ((uploaded_file.nil?) || (uploaded_file == ''))
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
        uploaded_file = params[:product][:image_file]
        save_file(uploaded_file) unless ((uploaded_file.nil?) || (uploaded_file == '') || (@product.image_file_name))
        format.html { redirect_to products_path, notice: t('products.update') }  # "Product was successfully updated."
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
    desired_quantity = params[:quantity].to_i
    if (desired_quantity > @product.quantity_in_stock)
      redirect_to @product, notice: t('products.add_to_cart_error')  # "The quantity cannot be greater than the amount in stock."
      return
    else
      session[:shopping_cart] = [] if (session[:shopping_cart].nil?)
      product_hash = { product_id: @product.id, quantity: desired_quantity }
      session[:shopping_cart] << product_hash
      redirect_to products_path
    end
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

  # GET /products/1/delete_image
  # Action to delete the product's image file
  def delete_image
    file_path = Rails.root.join('public', 'images', Rails.env, 'products', @product.image_file_name)
    File.delete(file_path)  # Delete image file from server
    @product.update_attributes(image_file_name: nil)  # Remove reference to image from db
    respond_to do |format|
      format.html { redirect_to edit_product_path(@product) }
      format.js  # Will add JavaScript to change image_tag to file_field upon deletion
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
      params.require(:product).permit(:product_type_id, :name, :price, :release_date, :description, :active, :image_file, :quantity_in_stock)
    end

    # Save uploaded file to server and store file name in product
    def save_file(new_file)
      file_name = "#{@product.id}-#{@product.name}.jpg"
      file_path = Rails.root.join('public', 'images', Rails.env, 'products', file_name)
      File.open(file_path, 'wb') { |file| file.write(new_file.read) }
      @product.update_attributes(:image_file_name => file_name)
    end

end
