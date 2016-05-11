class AddIndexToRepositoriesUser < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        # de-dup repositories_users table
        execute <<-SQL
          DELETE FROM repositories_users WHERE ctid NOT IN
             (SELECT MAX(ctid) FROM repositories_users GROUP BY repositories_users.*);        
        SQL
      end
      dir.down do
        # do nothing
      end
    end
    add_index :repositories_users, [:repository_id, :user_id], :unique => true
  end
end
