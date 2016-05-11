module RepositoriesHelper
  def the_recent_courses(courses, repo_name)
    case courses.length
      when 1
        "The class <em>#{course_link(courses[0])}</em> was recently taught by #{repo_name} staff."
      when 2
      "Recent classes at the #{repo_name} include <em>#{course_link(courses[0])}</em> and <em>#{course_link(courses[1])}</em>."
      else
      "Recent classes at the #{repo_name} include <em>#{course_link(courses[0])}</em>, <em>#{course_link(courses[1])}</em> and <em>#{course_link(courses[2])}</em>."
    end
  end
  
  def repo_name_or_new(name)
    name.blank? ? 'new library/archive' : name
  end
  def course_link(course)
    link_to(course.title, recent_show_course_url(course))
  end
end
