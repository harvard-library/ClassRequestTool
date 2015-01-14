class Course < ActiveRecord::Base
  include ActionDispatch::Routing::UrlFor
  include Rails.application.routes.url_helpers

  attr_accessible( :room_id, :repository_id, :user_ids, :item_attribute_ids, :primary_contact_id, :staff_involvement_ids, :sections_attributes, :additional_patrons_attributes, # associations
                   :title, :subject, :course_number, :affiliation, :number_of_students, :session_count,  #values
                   :comments,  :staff_involvement, :instruction_session, :goal,
                   :contact_username, :contact_first_name, :contact_last_name, :contact_email, :contact_phone,  #contact info
                   :status, :syllabus, :remove_syllabus, :external_syllabus, #syllabus
                   :pre_class_appt, :timeframe, :timeframe_2, :timeframe_3, :timeframe_4, :duration, #concrete schedule vals
                   :time_choice_1, :time_choice_2, :time_choice_3, :time_choice_4, # tentative schedule vals
                   :pre_class_appt_choice_1, :pre_class_appt_choice_2, :pre_class_appt_choice_3, #unused
                   :section_count, :session_count, :total_attendance  # stats
                   )

  has_and_belongs_to_many :users
  belongs_to :room
  belongs_to :repository
  has_many :sections, :dependent => :destroy
  accepts_nested_attributes_for :sections, :reject_if => ->(s){s.blank?}, :allow_destroy => true
  has_many :notes, :dependent => :destroy
  has_and_belongs_to_many :item_attributes
  has_many :assessments, :dependent => :destroy
  has_and_belongs_to_many :staff_involvements
  belongs_to :primary_contact, :class_name => 'User'
  has_many :additional_patrons, :dependent => :destroy, :autosave => true
  accepts_nested_attributes_for :additional_patrons, :reject_if => ->(ap){ap.blank?}, :allow_destroy => true
  
  validates_presence_of :title, :message => "can't be empty"
  validates_presence_of :contact_first_name, :contact_last_name
  validates_presence_of :contact_email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "Invalid email"
  validates_presence_of :contact_phone
  validates_presence_of :number_of_students, :message => "please enter a number"
  validates_presence_of :goal, :message => "please enter a goal"
  validates_presence_of :duration, :message => "please enter a duration in hours"

  mount_uploader :syllabus, SyllabusUploader
  
  default_scope group('courses.id').order('courses.created_at DESC')
  scope :unclaimed,   ->{ where(primary_contact_id: nil) }
  scope :claimed,     ->{ where('primary_contact_id IS NOT NULL') }
  scope :unscheduled, ->{ joins(:sections).where('sections.actual_date IS NULL') }
  scope :scheduled,   ->{ joins(:sections).where('actual_date IS NOT NULL') }
  scope :with_status, ->(status) { where(status: status) }
  scope :upcoming,    ->{ joins(:sections).where("MAX(actual_date) IS NOT NULL AND MAX(actual_date) > ?", DateTime.now) }
  scope :past,        ->{ joins(:sections).where("MAX(actual_date) IS NOT NULL AND MAX(actual_date) < ?", DateTime.now) }
  
  
  after_save :update_stats

  
  STATUS = ['Active', 'Cancelled', 'Closed']
  
#  STATUS = ['Scheduled, Unclaimed', 'Scheduled, Claimed', 'Claimed, Unscheduled', 'Unclaimed, Unscheduled', 'Homeless', 'Cancelled', 'Closed']
  validates_inclusion_of :status, :in => STATUS

  # Note: DO NOT replace MAX(actual_date) with alias, .count will error out
  #
  # Also Note: Subselect here is essentially just to hide
  #            the .group() clause from AR, so that .count doesn't return a hash
  #            Gross as hell, but better than having to remember when it's safe
  #            to call .count, and when you need to call .count.count
  #
  # Generally, this clause should be the last one applied to a relation being realized;
  #    in the case of .having() clauses which use MAX(actual_date), it MUST be the last applied
  #    or an error will be thrown, because actual_date doesn't exist in the final relation/select
  #    .limit is affected for performance reasons.
  # e.g.
  #    You should prefer Course.limit(10).ordered_by_last_section to Course.ordered_by_last_section.limit(10)
  # and
  #    Course.ordered_by_last_section.having('ANY_SQL_REFERENCING(actual_date)') will throw an exception,
  def self.ordered_by_last_section
    inner_scope = joins('LEFT OUTER JOIN sections ON sections.course_id = courses.id').
      group('courses.id').order('MAX(actual_date) DESC NULLS LAST, courses.created_at DESC')
    self.unscoped do
      from(inner_scope.as(table_name))
    end
  end

  def self.homeless
    where(:status => 'Homeless').ordered_by_last_section
  end

  # Headcounts represent after-the-fact, definite attendance numbers
  #   The following functions depend on Course::Session,
  #   defined at bottom of this file
  def headcount
    sections.map(&:headcount).reject(&:blank?).reduce(:+)
  end

  def avg_headcount
    hc = headcount
    if hc
      (hc / sections.map(&:headcount).reject(&:blank?).count.to_f).try(:round, 1)
    else
      nil
    end
  end

  # Returns an array of sessions, ordered by session number
  def sessions
    if sections.blank? || (sections.length == 1 && sections[0].id.nil?)      # This handles the case of a new course with a new session & section
      sesh = { sections[0].session => [sections[0]] }
    else
      sesh = sections.order(:session).group_by(&:session)
    end
  end
  
  # Returns a repo name, whether the course repo is defined yet or not
  def repo_name
    self.repository.blank? ? 'Unassigned' : self.repository.name
  end
  
  def scheduled?
    if self.sections.blank?
      secheduled = false
    else
      scheduled = true
      self.sections.each do |section|
        if section.actual_date.blank?
          scheduled = false
          break;
        end
      end
    end
    scheduled
  end
  
  def claimed?
    not(self.primary_contact.blank?)
  end
  
  def homeless?
    self.repository.blank?
  end
  
  # Quick update of course stats with direct db query
  def update_stats
    nsections   = self.sections.select{ |s| 1 == s.session }.count
    nsessions   = self.session_count = self.sections.map{ |s| s.session }.max.to_i
    nattendance  = self.sections.inject(0){ |sum, s| sum + s.headcount.to_i }
   
    connection = ActiveRecord::Base.connection
    sql = %Q(UPDATE "courses" SET section_count=#{nsections}, session_count=#{nsessions}, total_attendance=#{nattendance} WHERE courses.id=#{self.id})
    connection.execute( sql )

# 
#     self.update_columns({ 
#       :section_count    => self.sections.select{ |s| 1 == s.session }.count,            # Assumes that the first session gives the correct section count
#       :session_count    => self.session_count = self.sections.map{ |s| s.session }.max, # Looks for the max session number to give the number of unique sessions
#       :total_attendance => self.sections.inject{ |sum, s| sum + s.headcount }           # Just sums the headcount for each section/sesssion 
#     })
  end
  
  # Class functions
  def self.update_all_stats
    Course.all.each do |course|
      course.update_stats
    end
  end
  
  # Internal class for attaching functions to sessions
  class Session < Array
    def headcount
      map(&:headcount).reject(&:blank?).reduce(:+)
    end

    def avg_headcount
      hc = headcount
      if hc
        (headcount / map(&:headcount).reject(&:blank?).count.to_f).try(:round, 1)
      else
        nil
      end
    end
  end

end
