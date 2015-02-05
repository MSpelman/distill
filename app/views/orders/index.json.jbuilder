json.array!(@orders) do |order|
  json.extract! order, :id, :order_status_id, :pickup_date, :order_date
  json.url order_url(order, format: :json)
end
