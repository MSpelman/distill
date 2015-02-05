json.array!(@users) do |user|
  json.extract! user, :id, :email, :hashed_password, :name, :address_1, :address_2, :apt_number, :city, :state, :zip_code, :newsletter, :active, :admin
  json.url user_url(user, format: :json)
end
