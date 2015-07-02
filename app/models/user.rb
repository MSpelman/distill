require 'digest'
class User < ActiveRecord::Base
  attr_accessor :password
  
  validates_uniqueness_of :email
  validates_length_of :email, :within => 5..50
  validates_format_of :email, :with => /\A[^@][\w.-]+@[\w.-]+[.][a-z]{2,4}\z/i
  
  validates_confirmation_of :password
  validates_length_of :password, :within => 6..20, :if => :password_required?
  # Add format check to make sure have letters/numbers/upper & lower case/punctuation

  validates_presence_of :name

  validates_uniqueness_of :receive_customer_inquiry, :if => :receives_inquiries?
  validate :active_admin_user, :if => :receives_inquiries?

  # validates_length of :state to 2
  # validates_length of :zip_code to 5

  has_many :orders
  has_many :comments
  # Can create aliases for messages, e.g. sent_messages, owned_messages, and received_messages
  has_many :outgoing_messages, :class_name => 'Message', :foreign_key => 'from_user_id'
  has_many :incoming_messages, :class_name => 'Message', :foreign_key => 'owner_user_id'
  has_many :recipient_users
  has_many :messages, through: :recipient_users

  scope :admin_only, lambda { where("users.admin = ?", true) }

  before_save :encrypt_new_password

  # Class method to login a user
  def self.authenticate(email, password)
    user = find_by_email(email)
    return user if (user && (user.active == true) && user.authenticated?(password))
  end

  # Verifies the user entered the correct password
  def authenticated?(password)
    self.hashed_password == encrypt(password)
  end

  # Returns the user's name and email for display purposes
  def name_and_email
    "#{name} (#{email})"
  end

  # Returns both the user's incoming and outgoing messages
  def all_messages
    Message.where("(owner_user_id = ?) OR ((from_user_id = ?) AND (copied_message_id IS NULL))", self.id, self.id)
  end

  # Returns the messages that should display in the user's inbox
  def inbox
    Message.where("(owner_user_id = ?) AND ((deleted IS NULL) OR (deleted <> ?))", self.id, true)
  end

  # Returns the messages that should display in the user's sent mail view
  def sent_messages
    Message.where("(((from_user_id = ?) AND (copied_message_id IS NULL)) AND ((deleted IS NULL) OR (deleted <> ?)))", self.id, true)
  end

  protected

  # Encrypts the newly entered password before saving
  def encrypt_new_password
    return if password.blank?
    self.hashed_password = encrypt(password)
  end

  # Only validate the password field if the user record does not already have one
  # or the user modified it
  def password_required?
    hashed_password.blank? || password.present?
  end

  # Encrypts the user entered password for storage/comparison
  def encrypt(string)
    Digest::SHA1.hexdigest(string)  # need to update with stronger encryption
  end

  private

  # Validates that the user selected to receive customer inquiries is active 
  # (so there is someone to receive them) and an admin user (so messages don't accidently
  # go to another customer!)
  def active_admin_user
    if ((!admin) || (!active))
      errors.add(receive_inquires_error, " - Only active admin users can receive customer inquires.")  # " - Only active admin users can receive customer inquires."
    end
  end

  # Error message to display if an inappropriate user is selected to receive inquiries
  def receive_inquires_error
    "Receive Customer Inquiry Error"  # "Receive Customer Inquiry Error"
  end

  def receives_inquiries?
    receive_customer_inquiry
  end

end
