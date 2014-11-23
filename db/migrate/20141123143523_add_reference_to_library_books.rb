class AddReferenceToLibraryBooks < ActiveRecord::Migration
  def change
    add_column :library_books, :reference, :boolean, default: false
  end
end
