json.array!(@recipient_users) do |recipient_user|
  json.extract! recipient_user, :id, :message_id, :user_id
  json.url recipient_user_url(recipient_user, format: :json)
end
