class CreateBookingsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :bookings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :inventory, null: false, foreign_key: true
      t.string :ref_no
      t.date :borrow_date
      t.date :return_date
      t.integer :status, default: 0
      t.decimal :overdue_fee
      t.timestamps
    end
  end
end
