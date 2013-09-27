class Assessment < ActiveRecord::Base
  include ActionDispatch::Routing::UrlFor
  include Rails.application.routes.url_helpers
  attr_accessible :using_materials, :involvement, :staff_experience, :staff_availability, :space, :request_materials, :digital_collections, :involve_again, :not_involve_again, :better_future, :request_course, :catalogs, :comments
  
  belongs_to :course
  
  INVOLVEMENT = ['Class visit to see particular materials', 'Assisted in selecting materials for viewing in class', 'Presentation on use of primary sources in research', 'Class orientation in preparation for research assignment', 'Suggestions for materials appropriate to student research', 'Presentation on how to locate archival or rare book sources', 'Coordination of digital imaging for class use', 'Coordination of special projects (exhibits, etc.)', 'Other']

  def new_assessment_email
    # if assigned users is empty, send to all admins of tool 
    if self.course.users.nil? || self.course.users.blank?
      admins = ""
      User.all(:conditions => {:admin => true}).collect{|a| admins = a.email + ","}
      Email.create(
        :from => DEFAULT_MAILER_SENDER,
        :reply_to => DEFAULT_MAILER_SENDER,
        :to => admins,
        :subject => "[ClassRequestTool] Class Assessment Received!",
        :body => "<p>An assessment has been received for one of your classes. Great to see you are getting feedback on your hard work. See the details <a href='#{ROOT_URL}#{assessment_path(self)}'> here</a>.</p>"
      )
    # if assigned users is not empty, send to all users assigned to course selected
    else
      users = ""
      self.course.users.collect{|u| users = u.email + ","}
      Email.create(
        :from => DEFAULT_MAILER_SENDER,
        :reply_to => DEFAULT_MAILER_SENDER,
        :to => users,
        :subject => "[ClassRequestTool] Class Assessment Received!",
        :body => "<p>An assessment has been received for one of your classes. Great to see you are getting feedback on your hard work. See the details <a href='#{ROOT_URL}#{assessment_path(self)}'> here</a>.</p>"
      )  
    end  
  end
end
