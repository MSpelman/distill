json.array!(@order_products) do |order_product|
  json.extract! order_product, :id, :order_id, :product_id, :quantity
  json.url order_product_url(order_product, format: :json)
end
