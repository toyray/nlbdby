class AddIndexesToBooksAndLibraries < ActiveRecord::Migration
  def change
    add_index :books, :brn, unique: true
    add_index :libraries, :name, unique: true
  end
end
