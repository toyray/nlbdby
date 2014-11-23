class AddSingaporeToLibraryBooks < ActiveRecord::Migration
  def change
    add_column :library_books, :singapore, :boolean, default: false
  end
end
