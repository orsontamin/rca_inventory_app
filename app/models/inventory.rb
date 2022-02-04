class Inventory < ActiveRecord::Base
  has_one_attached :photos

  has_many :bookings

  scope :is_available, -> { where(available: true) }
end
