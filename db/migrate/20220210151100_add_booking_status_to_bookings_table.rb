class AddBookingStatusToBookingsTable < ActiveRecord::Migration[7.0]
  def change
    add_column :bookings, :booking_status, :string
  end
end
