json.array!(@comments) do |comment|
  json.extract! comment, :id, :summary, :detail, :rating, :active
  json.url comment_url(comment, format: :json)
end
