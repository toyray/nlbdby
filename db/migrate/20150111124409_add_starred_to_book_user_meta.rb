class AddStarredToBookUserMeta < ActiveRecord::Migration
  def change
    add_column :book_user_meta, :starred, :bool, default: false
  end
end
