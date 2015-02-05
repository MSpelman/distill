class OrderProduct < ActiveRecord::Base

  validates_presence_of :product_id
  validates_presence_of :quantity
  
  belongs_to :product
  belongs_to :order

  # Method to display the price of the product multiplied by the quantity of the product
  # the user ordered
  def unit_price_x_quantity
    price = unit_price
    price = product.price if price.nil?
    "$#{(price * quantity)} #{I18n.t('order_products.plus_tax')}"  # "+ tax"
  end

  # Method to display the product name along with the per unit price
  def product_name_with_unit_price
    price = unit_price
    price = product.price if price.nil?
    "#{product.name} ($#{price})"
  end
end