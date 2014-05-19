# Conversion from courses holding all the information about
#   sections to a relation structured thusly:
#
#  +----------------+          +--------------+
#  |                |          |    Section   |
#  |                |         /+--------------+
#  |   Course       |-|-----o--|  Session ID  |
#  |                |         \|              |
#  |                |          |              |
#  +----------------+          +--------------+
#
# The primary advantages of these changes are:
#
#   * Arbitrary numbers of sections/sessions can be supported
#   * De-bloating the Course table
#   * Disambiguating the time_choice fields, which were serving
#        double duty as multiple choices per session and
#        single choices per multi-session

class CreateSections < ActiveRecord::Migration
  class Course < ActiveRecord::Base
    # guard class to prevent validations, etc.
    attr_protected nil
    has_many :sections
  end

  class Section < ActiveRecord::Base
    # guard class to prevent validations, etc.
    # Used for inserts to provide datetime parsing
    attr_protected nil
    belongs_to :course
  end

  # Arrays of column/method names as symbols
  CHOICE_COLS = (1..4).map {|i| "time_choice_#{i}".to_sym}
  TIMEFRAME_COLS = [:timeframe] + (2..4).map {|i| "timeframe_#{i}".to_sym }

  def up
    create_table :sections do |t|
      t.datetime :requested_dates, :array => true
      t.datetime :actual_date

      t.integer :session, :null => false, :default => 1

      t.references :course
      t.references :room

      t.timestamps
    end

    add_index :sections, :actual_date
    add_index :sections, :course_id

    Section.reset_column_information

    errors = []
    Course.all.each do |course|
      requested_dates = CHOICE_COLS.map {|method| course.__send__(method)}.reject(&:nil?)
      timeframes = TIMEFRAME_COLS.map {|col| course.__send__ col}.reject(&:nil?)

      case course.course_sessions
      when 'Single Session'
        errors << course.id if timeframes.count > 1
        actual_date = course.timeframe
        Section.create :actual_date => actual_date, :requested_dates => requested_dates, :course_id => course.id, :room_id => course.room_id
      when /Multiple Sessions/
        errors << course.id if timeframes.count < 2 and requested_dates.count < 2
        TIMEFRAME_COLS.each.with_index(1) do |col, i|
          session = (course.course_sessions.match(/Different/) ? i : 1)
          actual_date = course.__send__(col)
          if actual_date || requested_dates[i-1]
            Section.create :actual_date => actual_date, :requested_dates => requested_dates[i-1,1], :course_id => course.id, :room_id => course.room_id, :session => session
          end
        end
      else
        errors << course.id
      end
    end # END Course.all

    raise ActiveRecord::ActiveRecordError.new("Null or incorrect 'course_sessions' field for courses with ids:\n\t#{errors}\n") unless errors.blank?

    change_table :courses do |t|
      CHOICE_COLS.each do |col|
        t.remove col
      end
      t.remove_index :timeframe
      TIMEFRAME_COLS.each do |col|
        t.remove col
      end
      t.remove_index :course_sessions
      t.remove :course_sessions

      t.remove :room_id
    end
  end

  # Notes on what won't cleanly reverse:
  #   Original model has a single room_id, so courses with sections located in different rooms will raise an error
  #   Original model has a hard limit of four timeframes, more than four sections will raise an error
  #   Any time choices past the first for a session will be silently discarded (not important enough to raise an error)
  def down
    change_table :courses do |t|
      CHOICE_COLS.each do |col|
        t.datetime col
      end
      TIMEFRAME_COLS.each do |col|
        t.datetime col
      end
      t.references :room
      t.string :course_sessions
      t.index :course_sessions
      t.index :timeframe
    end # END change_table :courses

    Course.reset_column_information

    errors = []
    Course.includes(:sections).each do |course|
      sessions = course.sections.pluck(:session).uniq.sort
      sections = course.sections

      errors << course.id unless sections.map(&:room_id).uniq.count == 1

      course.room_id = sections.first.room_id

      if sections.count == 1
        course.course_sessions = 'Single Session'
        course.timeframe = sections.first.actual_date
        # Fill choice cols from requested_dates
        course.attributes = CHOICE_COLS.zip(sections.first.requested_dates || []).to_h
      elsif sections.count > 1 && sections.count <= 4
        # tag course_sessions appropriately based on number of sessions
        course.course_sessions = "Multiple Sessions, #{sessions.count == 1 ? 'Same Materials' : 'Different Materials'}"
        # Fill timeframe cols from section dates, choice colls from first requested dates
        course.attributes = TIMEFRAME_COLS.zip(sections.map(&:actual_date)).to_h.merge(
                               CHOICE_COLS.zip(sections.map(&:requested_dates).map {|rd| rd.try(:first)}).to_h)
      else
        errors << course.id
      end
      course.save!
    end # END Course.include...each

    raise ActiveRecord::ActiveRecordError.new("No sections present for courses with ids:\n\t#{errors}\n") unless errors.blank?

    drop_table :sections
  end
end
