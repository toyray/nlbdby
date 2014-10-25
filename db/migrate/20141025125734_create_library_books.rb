class CreateLibraryBooks < ActiveRecord::Migration
  def change
    create_table :library_books do |t|
      t.references :library, index: true
      t.references :book, index: true
      t.boolean :available, default: false
      t.timestamps
    end
  end
end
