class Order < ActiveRecord::Base
  attr_accessor :earliest_pickup_date

  validates_presence_of :pickup_date
  validate :future_pickup_date, :if => :pickup_date_entered?

  belongs_to :order_status
  belongs_to :cancel_reason
  belongs_to :user
  has_many :order_products
  accepts_nested_attributes_for :order_products
  has_many :products, through: :order_products

  default_scope lambda { order('orders.order_date') }
  scope :new_orders, lambda { where("orders.order_status_id = ?", 1) }
  scope :filled_orders, lambda { where("orders.order_status_id = ?", 2) }
  scope :picked_up_orders, lambda { where("orders.order_status_id = ?", 3) }
  scope :canceled_orders, lambda { where("orders.order_status_id = ?", 4) }

  # If the order is already completed (picked-up) this method returns the saved off
  # product total, tax, and total amount due.  If the order is not completed it calculates
  # these values using the current price of each product.
  def calculate_totals
    totals = {}
    if self.amount_due.nil?
      total = 0.00
      order_products.each do |order_product|
        price = order_product.unit_price
        price = order_product.product.price if price.nil?
        total = total + (price * order_product.quantity)
      end
      totals[:product_total] = total
      totals[:tax] = total * 0.055
      totals[:amount_due] = total + totals[:tax]
    else
      totals[:product_total] = self.product_total
      totals[:tax] = self.tax
      totals[:amount_due] = self.amount_due
    end
    return totals
  end

  private

  # Validates that the pickup date is not in the past and not prior to the release date
  # of any of the products on the order.
  def future_pickup_date
    # Model does not have access to session (and thus the products in the shopping cart);
    # need to pass in the earliest allowable pickup date
    earliest_date = earliest_pickup_date
    earliest_date = Date.today if earliest_date.nil?
    if pickup_date < earliest_date
      errors.add(pickup_date_error, "#{I18n.t('orders.date_must_be')} #{earliest_date} #{I18n.t('orders.or_later')}")  # " - The pickup date must be #{earliest_date} or later."
    end
  end

  # Error message to display if there is a problem with the user entered pickup date
  def pickup_date_error
    I18n.t('orders.pickup_date_error')  # "Pickup Date Error"
  end

  # Determines if a pickup date was entered, and thus if the pickup date needs validation
  def pickup_date_entered?
    pickup_date.present?
  end
  
end
