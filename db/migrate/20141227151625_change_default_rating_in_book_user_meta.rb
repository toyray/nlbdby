class ChangeDefaultRatingInBookUserMeta < ActiveRecord::Migration
  def change
    change_column_default(:book_user_meta, :rating, 3)
  end
end
