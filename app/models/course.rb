class Course < ActiveRecord::Base
  include ActionDispatch::Routing::UrlFor
  include Rails.application.routes.url_helpers

  attr_accessible( :room_id, :repository_id, :user_ids, :item_attribute_ids, :primary_contact_id, :staff_involvement_ids, :sections_attributes, # associations
                   :title, :subject, :course_number, :affiliation, :number_of_students, :session_count,  #values
                   :comments,  :staff_involvement, :instruction_session, :goal,
                   :contact_username, :contact_first_name, :contact_last_name, :contact_email, :contact_phone, #contact info
                   :status, :file, :remove_file, :external_syllabus, #syllabus
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

  mount_uploader :file, FileUploader

  STATUS = ['Scheduled, Unclaimed', 'Scheduled, Claimed', 'Claimed, Unscheduled', 'Unclaimed, Unscheduled', 'Homeless', 'Cancelled', 'Closed']
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

  def self.unscheduled_unclaimed
    where(:status => 'Unclaimed, Unscheduled').ordered_by_last_section
  end

  def self.scheduled_unclaimed
    where(:status => 'Scheduled, Unclaimed').ordered_by_last_section
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

  def new_request_email
    # send email to requester
    Email.create(
      :from => DEFAULT_MAILER_SENDER,
      :reply_to => DEFAULT_MAILER_SENDER,
      :to => self.contact_email,
      :subject => "[ClassRequestTool] Class Request Successfully Submitted for #{self.title}",
      :body => "<p>Your class request has been successfully submitted for #{self.title}.</p>
      <p>You may review your request <a href='http://#{ROOT_URL}#{course_path(self)}'>here</a> and update it with any new details or comments by leaving a note for staff.</p>
      <p>Thank you for your request. We look forward to working with you.</p>"
    )
    # if repository is empty (homeless), send to all admins of tool
    if self.repository.nil? || self.repository.blank?
      admins = User.where('admin = ? OR superadmin = ?', true, true).collect{|a| a.email + ","}
      Email.create(
        :from => DEFAULT_MAILER_SENDER,
        :reply_to => DEFAULT_MAILER_SENDER,
        :to => admins.join(", "),
        :subject => "[ClassRequestTool] A New Homeless Class Request has been Received",
        :body => "<p>A new homeless class request has been received in the Class Request Tool.</p>
        <p>
        Library/Archive: Not yet assigned<br />
        <a href='http://#{ROOT_URL}#{course_path(self)}'>#{self.title}</a><br />
        Subject: #{self.subject}<br />
        Course Number: #{self.course_number}<br />
        Affiliation: #{self.affiliation}<br />
        Number of Students: #{self.number_of_students}<br />
        Syllabus: #{self.external_syllabus}<br />
        </p>
        <p>If this class is appropriate for your library or archive, please, <a href='http://#{ROOT_URL}#{edit_course_path(self)}'>edit the course</a> and assign it to your repository.</p>"
      )

    # if repository is not empty, send to all users assigned to repository selected
    else
      users = self.repository.users.collect{|u| u.email}
      superadmins = User.all(:conditions => {:superadmin => true}).collect{|s| s.email}
      users << superadmins
      users.flatten!
      repository = self.repository.nil? ? 'Not yet assigned' : self.repository.name
      Email.create(
        :from => DEFAULT_MAILER_SENDER,
        :reply_to => DEFAULT_MAILER_SENDER,
        :to => users.join(", "),
        :subject => "[ClassRequestTool] A new class request has been received for #{repository}",
        :body => "<p>
        Library/Archive: #{repository}<br />
        <a href='http://#{ROOT_URL}#{course_path(self)}'>#{self.title}</a><br />
        Subject: #{self.subject}<br />
        Course Number: #{self.course_number}<br />
        Affiliation: #{self.affiliation}<br />
        Number of Students: #{self.number_of_students}<br />
        Syllabus: #{self.external_syllabus}<br />
        </p>
        <p>If you wish to manage or confirm details, claim this class or assign it to another staff member at #{repository}, please <a href='http://#{ROOT_URL}#{edit_course_path(self)}'>edit the course</a>.</p>"
      )
    end
  end

  def send_cancellation_email
    # Send to primary contact, if exists, and to first staff contact with email
    emails = Array.new
    unless self.primary_contact.nil? || self.primary_contact.email.blank?
      emails << primary_contact.email
    end
    unless self.users.nil?
      self.users.each do |user|
        unless user.email.blank?
          email << user.email
          break
        end
      end
    end
    
    binding.pry

    # Send email
    Email.create(
      :from => DEFAULT_MAILER_SENDER,
      :reply_to => DEFAULT_MAILER_SENDER,
      :to => emails.join(','),
      :subject => "Class cancellation confirmation",
      :body => "<p>The class request for #{self.title} has been cancelled. We maintain a record of this class request.</p>
      <p>If you have any questions or additional details to share, please add a note to the <a href='http://#{ROOT_URL}#{course_path(self)}'>class request</a>.</p>"
    )
  end

  def send_repo_change_email
    # send to all users of selected repository
      users = self.repository.users.collect{|u| u.email}
      superadmins = User.all(:conditions => {:superadmin => true}).collect{|s| s.email}
      users << superadmins
      users.flatten!
      repository = self.repository.nil? ? 'Not yet assigned' : self.repository.name
      Email.create(
        :from => DEFAULT_MAILER_SENDER,
        :reply_to => DEFAULT_MAILER_SENDER,
        :to => users.join(", "),
        :subject => "[ClassRequestTool] A Class has been Transferred to #{repository}",
        :body => "<p>A class has been transferred to #{repository}. This may be a formerly Homeless class or a class another repository has suggested would be more appropriate for #{repository}.</p>
        <p>
        Library/Archive: #{repository}<br />
        <a href='http://#{ROOT_URL}#{course_path(self)}'>#{self.title}</a><br />
        Subject: #{self.subject}<br />
        Course Number: #{self.course_number}<br />
        Affiliation: #{self.affiliation}<br />
        Number of Students: #{self.number_of_students}<br />
        Syllabus: #{self.external_syllabus}<br />
        </p>
        <p>If you wish to manage or confirm details, claim this class or assign it to another staff member at #{repository}, please <a href='http://#{ROOT_URL}#{edit_course_path(self)}'>edit the course</a>.</p>"
      )
  end

  def send_staff_change_email(current_user)
    # send to assigned staff members
    emails = self.users.collect{|u| u == current_user ? '' : u.email}
    unless self.primary_contact.nil? || self.primary_contact.blank? || self.primary_contact == current_user
      emails << self.primary_contact.email
    end
    repository = self.repository.nil? ? 'Not yet assigned' : self.repository.name
    Email.create(
      :from => DEFAULT_MAILER_SENDER,
      :reply_to => DEFAULT_MAILER_SENDER,
      :to => emails.join(", "),
      :subject => "[ClassRequestTool] You have been assigned a class",
      :body => "<p>You have been assigned to a class for #{repository}.</p>
      <p>
      Library/Archive: #{repository}<br />
      <a href='http://#{ROOT_URL}#{course_path(self)}'>#{self.title}</a><br />
      Subject: #{self.subject}<br />
      Course Number: #{self.course_number}<br />
      Affiliation: #{self.affiliation}<br />
      Number of Students: #{self.number_of_students}<br />
      Syllabus: #{self.external_syllabus}<br />
      </p>
      <p>Please <a href='http://#{ROOT_URL}#{edit_course_path(self)}'>confirm the class date and time</a> and if applicable, add the class to your event management system (e.g. Aeon) and/or room calendar.</p>"
    )
  end

  def send_timeframe_change_email
    # figure out if there is a primary contact, if not send to first staff contact with email
    unless self.primary_contact.nil? || self.primary_contact.email.blank?
      email = primary_contact.email
      name = "#{self.primary_contact.full_name}"
    else
      unless self.users.nil?
        self.users.each do |user|
          unless user.email.blank?
            email = user.email
            name = "#{user.full_name}"
            break
          end
        end
      end
    end
    repository = self.repository.nil? ? 'Not yet assigned' : self.repository.name
    unless self.pre_class_appt.nil? || self.pre_class_appt.blank?
      pre_class = "<p>Additionally, your pre-class planning appointment is scheduled for #{self.pre_class_appt} with #{name} at #{repository}.</p>"
    else
      pre_class = ""
    end

    # send email to requester
    Email.create(
      :from => DEFAULT_MAILER_SENDER,
      :reply_to => DEFAULT_MAILER_SENDER,
      :to => self.contact_email,
      :subject => "Your class at #{repository} has been confirmed.",
      :body => "<p>Thank you for submitting your request for a class session at #{repository}. The request has been reviewed and confirmed.</p>
      <p>Title: <a href='http://#{ROOT_URL}#{course_path(self)}'>#{self.title}</a><br />
      Confirmed Date: #{self.sections.first.try(:actual_date)}<br />
      Duration: #{self.duration} hours<br />
      Staff contact:<a href='mailto:#{email}'> #{name}</a>
      </p>
      <p>If you have any questions or additional details to share, please add a note to the <a href='http://#{ROOT_URL}#{course_path(self)}'>class request</a>.</p>
      <p>#{pre_class}</p>"
    )
  end

  def send_assessment_email
    # send email to requester
    repository = self.repository.nil? ? 'Not yet assigned' : self.repository.name
    Email.create(
      :from => DEFAULT_MAILER_SENDER,
      :reply_to => DEFAULT_MAILER_SENDER,
      :to => self.contact_email,
      :subject => "[ClassRequestTool] Please Assess your Recent Class at #{repository}",
      :body => "<p>Your class session</p>
      <p>
      Library/Archive: #{repository}<br />
      <a href='http://#{ROOT_URL}#{course_path(self)}'>#{self.title}</a><br />
      Subject: #{self.subject}<br />
      Course Number: #{self.course_number}<br />
      Affiliation: #{self.affiliation}<br />
      Number of Students: #{self.number_of_students}<br />
      Syllabus: #{self.external_syllabus}<br />
      </p>
      <p>was recently completed.</p>
      <p>If you would consider taking five minutes to help us improve our services by filling out <a href='http://#{ROOT_URL}#{new_assessment_path(:course_id => self.id)}'> a short assessment about your experience, we would greatly appreciate it.</a></p>
      <p>Thank you for utilizing #{repository} in your course. We hope to work with you again soon.</p>"
    )
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
