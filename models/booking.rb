class Booking < ActiveRecord::Base
  belongs_to :user
  belongs_to :product
  # attr_accessor :quantity

  scope :is_overdue, -> { where(booking_status: 'Overdue') }
  scope :is_pending, -> { where(booking_status: 'Pending') }

  before_save :default_values
  before_save :decrement_quantity

  # The overdue rate per day
   def overdue_rate
     1.00
   end

   # Return the days that has passed after deadline
   def due_days
     (DateTime.now - self.return_date).to_i
   end

   # Calculate the overdue fees.
   def overdue_fees
     overdue_rate * due_days
   end

  # Set the booking status to 'Pending' after user book a product.
  def default_values
    self.booking_status ||= 'Pending' if self.booking_status.nil?
  end

  def decrement_quantity
     product.update_attribute(:quantity, product.quantity-self.quantity)
     product.save
   end
end
