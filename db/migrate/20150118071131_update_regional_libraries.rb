class UpdateRegionalLibraries < ActiveRecord::Migration
  def up
    execute "UPDATE libraries SET regional = 1 WHERE name LIKE '%Regional%'"
  end

  def down
    # No action required
  end
end
