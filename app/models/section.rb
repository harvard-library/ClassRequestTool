# Sections represent discrete scheduled interactions associated with Courses
#   Any particular section represents a meeting of some number of people in a
#   single physical location, with an array of potential datetimes and/or a single
#   definite datetime.
#
# The session column is an integer tag for grouping sections; Sessions are effectively
#   an implicit object that contains sections, and are the actual objects dealt with
#   by many logical and UI functions.
#
# Example:  The Course "History of the Book" might have three Sessions(1,2,3), which are
#           each split over two dates or rooms, for a total of six sections.  In this case,
#           the sections table would look like this (some fields omitted)
#
#             | id | course_id | room_id | session |  actual_date  |
#             |----------------------------------------------------|
#             |  1 |        42 |       8 |       1 | 2014-12-10... | <- First session
#             |  2 |        42 |       4 |       1 | 2014-12-10... |
#             |  3 |        42 |      10 |       2 | 2014-12-17... | <- Second session
#             |  4 |        42 |      10 |       2 | 2014-12-18... |
#             |  5 |        42 |       2 |       3 | 2015-01-03... | <- Third session
#             |  6 |        42 |       6 |       3 | 2015-02-03... |
#             |----------------------------------------------------|

class Section < ActiveRecord::Base
  belongs_to :course
  belongs_to :room
  
end
