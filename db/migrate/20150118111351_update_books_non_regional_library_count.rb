class UpdateBooksNonRegionalLibraryCount < ActiveRecord::Migration
  def up
    # FIXME: This is slow!
    Book.all.each do |b|
      b.non_regional_library_count = b.libraries.merge(Library.non_regional).count
      b.save
    end
  end

  def down
    # No action required
  end
end
