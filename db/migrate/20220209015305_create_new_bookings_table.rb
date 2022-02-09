class CreateNewBookingsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :bookings do |t|
      t.integer :user_id
      t.integer :product_id
      t.date :booking_date
      t.date :return_date
      t.timestamps
    end
  end
end
