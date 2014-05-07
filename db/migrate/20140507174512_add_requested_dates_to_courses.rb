# This migration creates a datetime array column that will hold an arbitrary number of requested sessions
# The information from the time_choice_N fields is collapsed into said array column.

# Details of postgres arrays can be found here: http://www.postgresql.org/docs/9.3/static/arrays.html
# The relevant gem is 'postgres_ext'
class AddRequestedDatesToCourses < ActiveRecord::Migration
  class Course < ActiveRecord::Base
    # empty class to prevent validations, hooks, etc
  end

  def up
    add_column :courses, :requested_dates, :datetime, :array => true

    Course.reset_column_information

    rd_hash = Course.pluck_all(:id, :time_choice_1, :time_choice_2, :time_choice_3, :time_choice_4)
    rd_arrays = rd_hash.map(&:values).map { |vals| vals.reject(&:nil?) }

    rd_arrays.each do |ar|
      (id, *dates) = ar
      unless dates.empty?
        me = Course.find(id)
        me.requested_dates = dates
        me.save!
      end
    end

    [:time_choice_1, :time_choice_2, :time_choice_3, :time_choice_4].each do |col|
      remove_column :courses, col
    end
  end

  # This is a reversible migration, but note: values will be "left justified" across the
  #   time_choice_N fields after down runs, if they weren't originally.
  #   e.g., a record with time_choice_1 = nil, time_choice_2 = 5, etc, will have time_choice_1 = 5

  # There's no meaning to or enforcement of the order of the time_choice_N fields
  #   so it fundamentally doesn't matter - but it may make DB diffs inconsistent.
  def down
    [:time_choice_1, :time_choice_2, :time_choice_3, :time_choice_4].each do |col|
      add_column :courses, col, :datetime
    end

    Course.reset_column_information
    Course.where('requested_dates IS NOT NULL').each do |c|
      errors = []
      c.requested_dates.each_with_index do |el, i|
        if i > 3
          errors << "#{c.id}:#{c.title} - Time choice #{i + 1} is out of bounds."
        end
        c.send("time_choice_#{i + 1}=", el)
      end
      raise errors.join("\n") unless errors.empty?
      c.save!
    end

    remove_column :courses, :requested_dates
  end
end
