class CancelReason < ActiveRecord::Base
  validates_presence_of :name
  has_many :orders
end
