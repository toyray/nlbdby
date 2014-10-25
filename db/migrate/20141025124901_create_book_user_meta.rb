class CreateBookUserMeta < ActiveRecord::Migration
  def change
    create_table :book_user_meta do |t|
      t.references :book, index: true
      t.integer :rating, default: 2
      t.boolean :borrowed, default: false
      t.timestamps
    end
  end
end
