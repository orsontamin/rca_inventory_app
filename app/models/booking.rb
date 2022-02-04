class Booking < ActiveRecord::Base
  belongs_to :user
  belongs_to :inventory

  enum status: [:pending, :booked, :borrowed, :cancelled, :late]

  after_create :generate_ref_no

  after_create :set_return_date
  ###

  def generate_ref_no
    random_string = SecureRandom.hex(3)
    self.ref_no = random_string
    self.save
  end

  def set_return_date
    days_between = (return_date.to_date - borrow_date.to_date).to_i
    return_date = days_between + 14
    self.save
  end

end
