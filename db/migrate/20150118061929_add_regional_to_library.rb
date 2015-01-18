class AddRegionalToLibrary < ActiveRecord::Migration
  def change
    add_column :libraries, :regional, :boolean, null: false, default: false
  end
end
