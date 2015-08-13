class State < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :abbr

  has_many :users

  scope :active_only, lambda { where("states.active = ?", true) }

end
