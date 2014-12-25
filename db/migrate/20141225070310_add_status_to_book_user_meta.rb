class AddStatusToBookUserMeta < ActiveRecord::Migration
  def change
    add_column :book_user_meta, :status, :string, default: 'new'
    remove_column :book_user_meta, :borrowed
  end
end
