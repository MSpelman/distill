class MessageType < ActiveRecord::Base

  validates_presence_of :name

  has_many :messages

  scope :active_only, lambda { where("message_types.active = ?", true) }

end
