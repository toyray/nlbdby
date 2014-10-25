class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :brn
      t.string :title
      t.string :author
      t.integer :pages
      t.integer :height
      t.string :call_no
      t.string :section
      t.timestamps
    end
  end
end
