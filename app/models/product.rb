class Product < ActiveRecord::Base
  attr_accessor :image_file

  validates_presence_of :name
  validates_presence_of :product_type_id
  validates_presence_of :price
  validates_presence_of :quantity_in_stock
  validate :image_file_format, :if => :image_uploaded?

  belongs_to :product_type
  has_many :order_products
  has_many :orders, through: :order_products
  has_many :comments

  scope :active_only, lambda { where("products.active = ?", true) }

  # Method to display the product name along with the price per unit
  def name_with_unit_price
    "#{name} ($#{price})"
  end

  # Method to display the average user rating and number of reviews for the product
  def average_rating
    total = 0.0
    self.comments.each { |comment| total = total + comment.rating }
    number_of_ratings = self.comments.count
    return I18n.t('products.no_ratings') if (number_of_ratings == 0)  # "No Ratings"
    "#{total / number_of_ratings} (#{number_of_ratings} #{I18n.t('products.reviews')})"  # "reviews"
  end

  private

  # Determines if an image was uploaded by the user, and thus whether the extension needs
  # to be checked
  def image_uploaded?
    image_file.present?
  end

  # Verify uploaded file format
  def image_file_format
    if !(image_file.original_filename =~ /\.jpg\Z/)
      errors.add(file_format_error, I18n.t('products.needs_jpeg_format'))  # " - The file needs to be in JPEG (.jpg) format."
    end
  end

  # Error message to display if there is a problem with the uploaded file's format
  def file_format_error
    I18n.t('products.file_format_error')  # "File Format Error"
  end

end
