class Course < ActiveRecord::Base
  include ActionDispatch::Routing::UrlFor
  include Rails.application.routes.url_helpers

  attr_accessible( :room_id, :repository_id, :user_ids, :item_attribute_ids, :primary_contact_id, :staff_involvement_ids, 
                   :sections_attributes, :additional_patrons_attributes, :collections_attributes, # associations
                   :title, :subject, :course_number, :affiliation, :number_of_students, :session_count,  #values
                   :comments,  :staff_involvement, :instruction_session, :goal,
                   :contact_username, :contact_first_name, :contact_last_name, :contact_email, :contact_phone,  #contact info
                   :status, :syllabus, :remove_syllabus, :external_syllabus, #syllabus
                   :pre_class_appt, :timeframe, :timeframe_2, :timeframe_3, :timeframe_4, :duration, #concrete schedule vals
                   :time_choice_1, :time_choice_2, :time_choice_3, :time_choice_4, # tentative schedule vals
                   :pre_class_appt_choice_1, :pre_class_appt_choice_2, :pre_class_appt_choice_3, #unused
                   :section_count, :session_count, :total_attendance,  # stats
                   :first_date, :last_date, :scheduled
                   )

  has_and_belongs_to_many :users
  belongs_to :room
  belongs_to :repository
  has_many :notes, :dependent => :destroy
  has_and_belongs_to_many :item_attributes
  has_many :assessments, :dependent => :destroy
  has_and_belongs_to_many :staff_involvements
  belongs_to :primary_contact, :class_name => 'User'

  has_many :additional_patrons, :dependent => :destroy, :autosave => true
  accepts_nested_attributes_for :additional_patrons, :reject_if => ->(ap){ap.blank?}, :allow_destroy => true

  has_many :sections, :dependent => :destroy
  accepts_nested_attributes_for :sections, :reject_if => ->(s){s.nil?}, :allow_destroy => true
  
  validates_presence_of :title, :message => "can't be empty"
  validates_presence_of :contact_first_name, :contact_last_name
  validates_presence_of :contact_email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "Invalid email"
  validates_presence_of :contact_phone
  validates_presence_of :number_of_students, :message => "please enter a number"
  validates_presence_of :goal, :message => "please enter a goal"
  validates_presence_of :duration, :message => "please enter a duration in hours"

  mount_uploader :syllabus, SyllabusUploader
  
  scope :unclaimed,             ->{ where(primary_contact_id: nil) }
  scope :claimed,               ->{ where('primary_contact_id IS NOT NULL') }
  scope :unscheduled,           ->{ where(:scheduled => false) }
  scope :scheduled,             ->{ where(:scheduled => true) }
  scope :with_status,           ->(status) { where(status: status) }
  scope :upcoming,              ->{ where("last_date > ?", DateTime.now) }
  scope :past,                  ->{ where("last_date < ?", DateTime.now) }  
  scope :user_is_patron,        ->(email){ where(:contact_email => email) }
  scope :user_is_primary_staff, ->(id){ where(:primary_contact_id => id) }
  scope :user_is_staff,         ->(id_array){ where(:repository_id => id_array) }
  scope :order_by_first_date,   ->{ order('first_date DESC NULLS LAST') }  
  scope :order_by_last_date,    ->{ order('last_date DESC NULLS LAST') }  
  scope :order_by_submitted,    ->{ order('created_at DESC') }  


  after_save :update_stats

  
  STATUS = ['Active', 'Cancelled', 'Closed']  
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
  #    You should prefer Course.limit(10).order_by_last_date to Course.order_by_last_date.limit(10)
  # and
  #    Course.order_by_last_date.having('ANY_SQL_REFERENCING(actual_date)') will throw an exception,
#   def self.order_by_last_date
#     inner_scope = joins('LEFT OUTER JOIN sections ON sections.course_id = courses.id').
#       group('courses.id').order('MAX(actual_date) DESC NULLS LAST, courses.created_at DESC')
#     self.unscoped do
#       from(inner_scope.as(table_name))
#     end
#   end

  def self.homeless
    where(:status => 'Homeless').order_by_last_date
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
    if (sections.length == 1 && sections[0].course_id.nil?)      # This handles the case of a new unattached session
      sesh = { sections[0].session => [sections[0]] }
    else
      sesh = sections.order(:session).group_by(&:session)
    end
  end
  
  # Returns a repo name, whether the course repo is defined yet or not
  def repo_name
    self.homeless? ? 'Unassigned' : self.repository.name
  end
    
  def claimed?
    not(self.primary_contact_id.blank?)
  end
  
  def homeless?
    self.repository_id.blank?
  end
  
  # Quick update of course stats with direct db query
  def update_stats
  
    # Update section and session numbers
    nsections = nsessions = nattendance = 0
    
    # First and last dates
    first_date = last_date = nil
    
    # Scheduled
    scheduled = true
    self.sections.each do |s|
      nsections += 1 if s.session == 1
      nsessions = s.session.to_i if s.session > nsessions
      nattendance += s.headcount.to_i
      if s.actual_date
        first_date = s.actual_date if (first_date.nil? || s.actual_date < first_date)
        last_date = s.actual_date if (last_date.nil? || s.actual_date > last_date)
      elsif s.requested_dates
        scheduled = false
        requested_dates = s.requested_dates.reject { |d| d.blank? }.sort        
        first_date  = requested_dates.first if (first_date.nil? || requested_dates.first < first_date)
        last_date   = requested_dates.last if (last_date.nil? || requested_dates.last > last_date)
      else
        scheduled = false
      end
    end
    
    # Use update_column to avoid autosave issues
    self.update_column(:section_count, nsections)
    self.update_column(:session_count, nsessions)
    self.update_column(:total_attendance, nattendance)
    self.update_column(:first_date, first_date) unless first_date.nil?
    self.update_column(:last_date, last_date) unless first_date.nil?
    self.update_column(:scheduled, scheduled)
  end
  
  # Class functions
  # Implemented for the CSVExport class
  def self.csv_data(filters = [])
    fields = ["to_char(c.created_at, 'YYYY-MM-DD HH:MIam')",
              'title',
              'subject',
              'course_number',
              'affiliation',
              'contact_email',
              'contact_phone',
              'pre_class_appt',
              'r.name',               # Repositories column
              'u.first_name || u.last_name',
              'staff_involvement',
              'number_of_students',
              'status',
              'syllabus',
              'external_syllabus',
              'duration',
              'comments',
              'session_count',
              'goal',
              'contact_first_name',
              'contact_last_name',
              'contact_username',
              's.session',                                            # Sections column 
              's.id',                                                 # Sections column
              "to_char(s.actual_date, 'YYYY-MM-DD HH:MIam')",         # Sections column 
              's.headcount'                                           # Sections column
            ]
    
    header_row = []
    fields.each do |field|
      case field
      when "to_char(c.created_at, 'YYYY-MM-DD HH:MIam')"
        heading = 'Submitted'
      when 'r.name'
        heading = 'Repository'
      when 'u.first_name || u.last_name'
        heading = 'Primary staff contact'
      when 's.session'
        heading = 'Session'
      when 's.id'
        heading = 'Section ID'
      when "to_char(s.actual_date, 'YYYY-MM-DD HH:MIam')"
        heading = 'Section date'
      when 's.headcount'
        heading = 'Attendance'
      else
        heading = field.humanize
      end
      
      header_row << heading
    end
    
    select = "SELECT #{fields.join(',')} FROM courses c "
    joins = [
      "LEFT JOIN repositories r ON c.repository_id = r.id",
      "LEFT JOIN sections s ON s.course_id = c.id",
      "LEFT JOIN users u ON u.id = c.primary_contact_id"
    ]
    
    order = 'ORDER BY c.created_at ASC, s.session ASC NULLS LAST, s.actual_date ASC NULLS LAST'
    
    if filters.empty?
      sql = "#{select} #{joins.join(' ')} #{order}"
    else
      sql = "#{select} #{joins.join(' ')} WHERE #{filters.join(' AND ')} #{order}"
    end
    
    [header_row, sql]    
  end
  
  def self.update_all_stats
    courses = Course.all
    courses.each do |course|
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
  
  private
  
    # Convert form parameters to where clauses
    def where_filters(filters)
      where_filters = []
      
      unless filters[:repository.blank?]
        where_filters << "repositories.id = #{filters[:repository_id]}"
      end
    end
end
