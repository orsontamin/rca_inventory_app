require 'bcrypt'

class User < ActiveRecord::Base

  attr_accessor :password, :password_confirmation

# validations provided Active Record
  validates :full_name, presence: true
  validates :email, presence: true
  validates :password, presence: true
  validates :password_confirmation, presence: true
  has_many :products
  has_many :bookings
  # custom validation
  validate :password_and_confirmation_must_be_identical

  # callbacks
  before_save :hash_password

  # instance method to check if the password from login form is identical
  # to the password saved during sign up
  def authenticate(password)
    BCrypt::Password.new(self.password_digest) == password
  end


  private
    def password_and_confirmation_must_be_identical
      if self.password != self.password_confirmation
        errors.add(:password, 'must be identical to password confirmation.')
      end
    end

    def hash_password
      self.password_digest = BCrypt::Password.create(self.password)
    end
end
