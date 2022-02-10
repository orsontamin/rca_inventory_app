class Product < ActiveRecord::Base
  belongs_to :admin
  belongs_to :user
  has_many :bookings
  validates :title, presence: true
end
#belongs_to allows the model to CRUD.
