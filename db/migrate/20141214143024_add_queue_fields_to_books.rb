class AddQueueFieldsToBooks < ActiveRecord::Migration
  def change
    add_column :books, :status, :string, default: 'completed'
    add_column :books, :last_updated_at, :datetime
  end
end
