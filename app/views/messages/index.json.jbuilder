json.array!(@messages) do |message|
  json.extract! message, :id, :created_at, :from_user_id, :subject, :message_type_id, :read, :took_ownership_at
  json.url message_url(message, format: :json)
end
