module RepositoriesHelper
  def the_recent_courses(courses, repo_name)
    case courses.length
      when 1
        "The class <em>#{courses[0]}</em> was recently taught by #{repo_name} staff."
      when 2
        "Recent classes at the #{repo_name} include <em>#{courses[0]}</em> and <em>#{courses[1]}</em>."
      else
        *first, last = courses
        "Recent classes at the #{repo_name} include <em>#{first.join('</em>, <em>')}</em> and <em>#{last}</em>."
    end
  end
  
  def repo_name_or_new(name)
    name.blank? ? 'new library/archive' : name
  end
end
