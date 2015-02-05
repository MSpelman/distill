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

  # validates_length of :state to 2
  # validates_length of :zip_code to 5

  has_many :orders
  has_many :comments

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

end
