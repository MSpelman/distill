class Comment < ActiveRecord::Base
  validates_presence_of :summary
  validates_presence_of :rating

  belongs_to :product
  belongs_to :user

  scope :active_only, lambda { where("comments.active = ?", true) }

end
