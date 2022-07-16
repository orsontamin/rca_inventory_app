require 'bcrypt'

class Admin < ActiveRecord::Base

  attr_accessor :password, :password_confirmation

  validates :username, presence: true
  validates :email, presence: true
  validates :password, presence: true
  validates :password_confirmation, presence: true

  before_save :hash_password

  # Instance method to check if the password from login form is identical
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
