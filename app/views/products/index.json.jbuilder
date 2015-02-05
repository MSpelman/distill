json.array!(@products) do |product|
  json.extract! product, :id, :product_type_id, :name, :price, :release_date, :description, :active
  json.url product_url(product, format: :json)
end
