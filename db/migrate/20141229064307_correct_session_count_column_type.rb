class CorrectSessionCountColumnType < ActiveRecord::Migration
  def up
    execute("ALTER TABLE courses ALTER COLUMN session_count TYPE integer USING (coalesce(NULLIF(session_count, ''), '0')::integer);")
  end

  def down
    execute('ALTER TABLE courses ALTER COLUMN session_count TYPE varchar(255) USING (session_count::varchar);')
  end
end
