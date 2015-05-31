class ResetBookPagesAndHeight < ActiveRecord::Migration
  def up
    Book.where(height:99).update_all(height:0)
    Book.where(pages:999).update_all(pages:0)
  end

  def down
    Book.where(height:0).update_all(height:99)
    Book.where(pages:0).update_all(pages:999)
  end
end
