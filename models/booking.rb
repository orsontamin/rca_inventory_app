class Booking < ActiveRecord::Base
  belongs_to :user
  belongs_to :product

  #
  scope :is_overdue, -> { where("booking_status = 'Overdue'") }

  before_save :default_values
  # after_create :overdue?
  #after_create :quantity_remaining

  # def overdue?
  #   if due_date_absolute < Time.now.strftime('%d %B %Y')
  #     self.booking_status = 'Overdue'
  #     self.save
  #   end
  # end
  #
  # def due_date_absolute
  #   self.return_date.strftime('%d %B %Y')
  # end
  #
  # def overdue_rate
  #   1.00
  # end
  #
  # def overdue_fees
  #   overdue_rate * ((Time.now - self.booking_end) / 1.days)
  # end

  # Set the booking status to 'Pending' after booking items.
  def default_values
    self.booking_status ||= 'Pending' if self.booking_status.nil?
  end
end
