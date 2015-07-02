class Message < ActiveRecord::Base
  attr_accessor :recipient_user_id
  attr_accessor :fwd_note
  attr_accessor :require_recipient
  attr_accessor :require_type
  attr_accessor :require_subject

  validates_presence_of :recipient_user_id, :if => :require_recipient
  validates_presence_of :message_type_id, :if => :require_type
  validates_presence_of :subject, :if => :require_subject

  belongs_to :message_type
  belongs_to :from_user, :class_name => 'User'
  belongs_to :owner_user, :class_name => 'User'
  has_many :recipient_users
  accepts_nested_attributes_for :recipient_users
  has_many :users, through: :recipient_users
  has_many :copies, :class_name => 'Message', :foreign_key => 'copied_message_id'
  belongs_to :copied_message, :class_name => 'Message'
  has_many :children, :class_name => 'Message', :foreign_key => 'parent_id'
  belongs_to :parent, :class_name => 'Message'
  has_many :forwards, :class_name => 'Message', :foreign_key => 'forwarded_message_id'
  belongs_to :forwarded_message, :class_name => 'Message'

  default_scope lambda { order('messages.created_at DESC') }
  scope :not_deleted, lambda { where("(messages.deleted IS NULL) OR (messages.deleted <> ?)", true) }

  # Returns true if the incoming message has already been replied to
  def replied_to?
    self.children.length > 0
  end

  # Returns true if the outgoing message is a reply
  def reply?
    !(self.parent.nil?)
  end

  # Returns true if the incoming message has been forwarded to another user
  def forwarded?
    !(self.forwards.empty?)
  end

end
