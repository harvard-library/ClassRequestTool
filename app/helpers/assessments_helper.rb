module AssessmentsHelper
  def assessment_course(a)
    if a.course_id < 0
      'Test Course'
    else
      a.course ? link_to(a.course.title, a.course) : ''
    end
  end
end
