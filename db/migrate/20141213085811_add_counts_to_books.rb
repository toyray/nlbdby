class AddCountsToBooks < ActiveRecord::Migration
  def change
    add_column :books, :library_count, :integer, null: false, default: 0
    add_column :books, :available_count, :integer, null: false, default: 0
  end
end
