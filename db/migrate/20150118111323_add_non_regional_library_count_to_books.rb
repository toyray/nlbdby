class AddNonRegionalLibraryCountToBooks < ActiveRecord::Migration

  def self.up
    add_column :books, :non_regional_library_count, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :books, :non_regional_library_count
  end
end
