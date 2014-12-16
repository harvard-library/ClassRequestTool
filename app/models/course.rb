class Course < ActiveRecord::Base
  include ActionDispatch::Routing::UrlFor
  include Rails.application.routes.url_helpers

  attr_accessible( :room_id, :repository_id, :user_ids, :item_attribute_ids, :primary_contact_id, :staff_involvement_ids, :sections_attributes, # associations
                   :title, :subject, :course_number, :affiliation, :number_of_students, :session_count,  #values
                   :comments,  :staff_involvement, :instruction_session, :goal,
                   :contact_username, :contact_first_name, :contact_last_name, :contact_email, :contact_phone, #contact info
                   :status, :syllabus, :remove_syllabus, :external_syllabus, #syllabus
                   :pre_class_appt, :timeframe, :timeframe_2, :timeframe_3, :timeframe_4, :duration, #concrete schedule vals
                   :time_choice_1, :time_choice_2, :time_choice_3, :time_choice_4, # tentative schedule vals
                   :pre_class_appt_choice_1, :pre_class_appt_choice_2, :pre_class_appt_choice_3 #unused
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
    sesh = sections.group_by(&:session)
    sesh.keys.sort.reduce([]) {|result, key| result << Session.new(sesh[key]);result}
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
