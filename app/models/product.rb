class Product < ActiveRecord::Base

  validates_presence_of :name
  validates_presence_of :product_type_id
  validates_presence_of :price

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

end
