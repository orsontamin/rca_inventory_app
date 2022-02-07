class RemoveInventoryReferenceInBookings < ActiveRecord::Migration[7.0]
  def change
    remove_reference(:bookings, :inventory, foreign_key: true)
  end
end
