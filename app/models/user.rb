require 'digest'
class User < ActiveRecord::Base
  attr_accessor :password
  
  validates_uniqueness_of :email
  validates_length_of :email, :within => 5..50
  validates_format_of :email, :with => /\A[^@][\w.-]+@[\w.-]+[.][a-z]{2,4}\z/i
  
  validates_confirmation_of :password
  validates_length_of :password, :within => 6..20, :if => :password_required?
  validate :password_format, :if => :password_required?

  validates_presence_of :name
  validate :user_name_format, :if => :name_entered?

  validates_uniqueness_of :receive_customer_inquiry, :if => :receives_inquiries?
  validate :active_admin_user, :if => :receives_inquiries?

  validate :zip_code_format, :if => :zip_code_entered?

  has_many :orders
  has_many :comments
  has_many :outgoing_messages, :class_name => 'Message', :foreign_key => 'from_user_id'
  has_many :incoming_messages, :class_name => 'Message', :foreign_key => 'owner_user_id'
  has_many :recipient_users
  has_many :messages, through: :recipient_users
  belongs_to :state

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
  # (so there is someone to receive them) and an admin user (so messages don't
  # accidentally go to another customer!)
  def active_admin_user
    if ((!admin) || (!active))
      errors.add(receive_inquires_error, I18n.t('users.only_active_admin'))  # " - Only active admin users can receive customer inquires."
    end
  end

  # Error message to display if an inappropriate user is selected to receive inquiries
  def receive_inquires_error
    I18n.t('users.customer_inquiry_error')  # "Receive Customer Inquiry Error"
  end

  def receives_inquiries?
    receive_customer_inquiry
  end

  # Determines if a name was entered, and thus whether its format needs to be checked
  def name_entered?
    name.present?
  end

  # Validates that the user's name starts with a capital, only contains letters, and
  # includes a first and last name.
  # Assumes pieces of the name are separated by <space>, ', or -
  def user_name_format
    name_array = name.split(/ |'|-/)
    first = true
    errors.add(name_format_error, I18n.t('users.need_first_and_last')) if (name_array.size < 2)  # " - Must include first and last name."
    name_array.each do |piece|
      errors.add(name_format_error, I18n.t('users.first_name_capital')) if (first && (!(piece =~ /\A[A-Z][a-z]*\Z/)))  # " - First name must start with a capital and only contain letters."
      errors.add(name_format_error, I18n.t('users.letters_only')) if ((!first) && (!(piece =~ /\A[A-z]*\Z/)))  # " - Name must only contain letters."
      first = false
    end
  end

  # Error message to display if a user's name is not formatted correctly
  def name_format_error
    I18n.t('users.name_format_error')  # "Name Format Error"
  end

  # Determines if a zip code was entered, and thus whether its format needs to be checked
  def zip_code_entered?
    zip_code.present?
  end

  # Validates the user's zip code is either (5 alpha-numerics) OR (5 alpha-numerics, a
  # "-", then 4 numbers).  Letters are allowed in the first 5 characters to accommodate
  # Canadian and Mexican postal codes.
  def zip_code_format
    unless ((zip_code =~ /\A[A-z|0-9]{5}\Z/) || (zip_code =~ /\A[A-z|0-9]{5}-\d{4}\Z/))
      errors.add(zip_format_error, I18n.t('users.postal_code_format'))  # " - Postal code should be in the format ##### or #####-####."
    end
  end

  # Error message to display if a user's zip code is not formatted correctly
  def zip_format_error
    I18n.t('users.zip_format_error')  # "Postal Code Format Error"
  end

  # Validates the user's password is contains at least one letter, number, and punctuation
  # mark. No whitespace allowed.
  def password_format
    error_strings = []
    error_strings << I18n.t('users.needs_letter') if !(password =~ /[A-z]/)  # "needs at least one letter"
    error_strings << I18n.t('users.needs_number') if !(password =~ /[0-9]/)  # "needs at least one number"
    error_strings << I18n.t('users.needs_punctuation') if !(password =~ /[!@#$%^&*()_;:,.?]/)  # "needs at least one punctuation mark"
    error_strings << I18n.t('users.no_spaces') if (password =~ /\s/)  # "cannot contain spaces"
    return if (error_strings.size < 1)
    error_message = I18n.t('users.error_msg')  # "Password "
    error_strings.each_index do |index|
      if (index == 0)
        error_message += error_strings[index]
      elsif (index == (error_strings.size - 1))
        error_message += " and #{error_strings[index]}"
      else
        error_message += ", #{error_strings[index]}"
      end
    end
    errors.add(password_format_error, error_message)
  end

  # Error message to display if a user's password is not formatted correctly
  def password_format_error
    I18n.t('users.password_format_error')  # "Password Format Error"
  end

end
