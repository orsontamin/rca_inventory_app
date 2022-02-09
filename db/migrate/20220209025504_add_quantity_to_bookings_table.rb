class AddQuantityToBookingsTable < ActiveRecord::Migration[7.0]
  def change
    change_table :bookings do |t|
      t.integer :quantity
    end
  end
end
