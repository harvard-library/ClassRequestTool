# Since we don't need to persist the reports, we don't inherit from ActiveRecord::Base
class Report

  attr_accessor :report_filters


  @@stat_types = {
    :unique_class_requests => 'The number of unique class requests',
    :one_group_one_session => 'The number of classes where one group meets once',
    :multiple_sessions_one_group => 'The number of classes where one group meets several times and the number of sessions requested',
    :multiple_groups_one_session => 'The number of classes where several subgroups each meet once and the number of groups',
    :multiple_groups_multiple_sessions => 'The number of classes where several subgroups each meet several times and the number of groups',
    :attendance => 'Projected and actual class attendance and number of aggregate student visits'
#    :staff_distribution => 'Distribution of classes about primary staff contacts and additional staff'
  }
  
  def self.stat_types
    @@stat_types
  end
  
  # Builds the filter
  def build_filters(params)
    @report_filters = {
      :clauses => [],
      :displays => []
    }
    if params[:closed_only]
      @report_filters[:clauses] << "status='Closed'"
      @report_filters[:displays] << "Only closed classes"
    else
      @report_filters[:clauses] << "status!='Cancelled'"
      @report_filters[:displays] << "Active and closed classes"
   end
    
    unless params[:repo].blank?
      repo = Repository.find(params[:repo].to_i)
      @report_filters[:clauses] << "repository.id=#{params[:repo]}"
      @report_filters[:displays] << "For #{repo.name} only"    
    end
    
    unless params[:start_date].blank? || params[:end_date].blank? || (params[:end_date].to_time < params[:start_date].to_time)
      @report_filters[:clauses] << "updated_at > #{params[:start_date]} AND updated_at > #{params[:end_date]}"
      @report_filters[:displays] << "<ul class='no-bullets'><li>From: #{params[:start_date]}</li><li>To: #{params[:end_date]}</li>"    
    end
    @report_filters
  end
  
  def display(params)
    output = {}
    @@stat_types.keys.each do |statistic|
      if params[statistic]
        output[statistic] = calculate(statistic)
      end
    end
    output
  end
  
  def calculate(key)
    case key
      when :unique_class_requests
        where_clause = @report_filters[:clauses].clone
        sql =  %Q(SELECT COUNT(*) AS number_of_classes FROM courses WHERE #{where_clause.join(' AND ')})
        
      when :one_group_one_session
        where_clause = @report_filters[:clauses].clone
        where_clause << "section_count=1"
        where_clause << "session_count=1"
        sql =  %Q(SELECT COUNT(*) AS number_of_classes FROM courses WHERE #{where_clause.join(' AND ')})
        
      when :multiple_sessions_one_group
        where_clause = @report_filters[:clauses].clone
        where_clause << "section_count=1"
        where_clause << "session_count>1"
        sql =  %Q(SELECT COUNT(*) AS number_of_classes, AVG(session_count) AS average_sessions, STDDEV(session_count) AS std_dev, MAX(session_count) AS max_number_of_sessions )
        sql += %Q(FROM courses WHERE #{where_clause.join(' AND ')})
        
      when :multiple_groups_one_session
        where_clause = @report_filters[:clauses].clone
        where_clause << "section_count>1"
        where_clause << "session_count=1"
        sql =  %Q(SELECT COUNT(*) AS number_of_classes, AVG(section_count) AS average_groups, STDDEV(section_count) AS std_dev, MAX(section_count) AS max_number_of_groups )
        sql += %Q(FROM courses WHERE #{where_clause.join(' AND ')})
        
      when :multiple_groups_multiple_sessions
        where_clause = @report_filters[:clauses].clone
        where_clause << "section_count>1"
        where_clause << "session_count>1"
        sql =  %Q(SELECT COUNT(*) AS number_of_classes, AVG(section_count) AS average, STDDEV(section_count) AS std_dev, MAX(section_count) AS max_number_of_sessions )
        sql += %Q(FROM courses WHERE #{where_clause.join(' AND ')})
        
      when :attendance
        where_clause = @report_filters[:clauses].clone
        where_clause << 'total_attendance>0'
        sql =  %Q(SELECT COUNT(*) AS contributing_records, AVG(number_of_students) AS average_projected, AVG(total_attendance) AS average_actual, SUM(total_attendance) AS total_number_of_attendees )
        sql += %Q(FROM courses WHERE #{where_clause.join(' AND ')})
    end
    
    output = { :no_data => 'No data' }
    connection = ActiveRecord::Base.connection
    connection.execute( sql ).each do |result|
      output = result
    end
    output
  end

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end
  
end

=begin
Notes:
ALL FILTER ON CLOSED COURSES:
WHERE courses.status='Closed'

SESSIONS/SECTIONS
• Number of CRT unique requests (no matter how many sessions/sections each class had)
(NUMBER)    SELECT COUNT(*) FROM courses

PER COURSE:
  Number of sessions: SELECT c.title, MAX(s.session) FROM courses AS c INNER JOIN sections AS s ON c.id=s.course_id GROUP BY c.id
  CREATE TABLE session_temp (SELECT MAX(s.session) as sessions FROM courses AS c INNER JOIN sections AS s ON c.id=s.course_id GROUP BY c.id)
  Number of sections: SELECT DISTINCT c.title, COUNT(c.name) FROM courses AS c INNER JOIN sections AS s ON c.id=s.course_id GROUP BY c.id, s.session

ATTENDANCE
  Number of projected/estimated student attendees:            SELECT number_of_students FROM courses 
  Number of actual student attendees? (Captured on closing):  SELECT SUM(s.headcount) FROM courses AS c INNER JOIN sections AS s ON c.id=s.course_id GROUP BY c.id
• Number of times students visit (this requires intervention because our multi-session classes will provide a count of, say, 10, but they come 15 times in the semester. That's 150 students 


Median calculation in SQL
SELECT avg(t1.val) as median_val FROM (
SELECT @rownum:=@rownum+1 as `row_number`, tt.val
  FROM session_temp st,  (SELECT @rownum:=0) r
  WHERE 1
  -- put some where clause here
  ORDER BY st.sessions
) as t1, 
(
  SELECT count(*) as total_rows
  FROM temp_table tt
  WHERE 1
  -- put same where clause here
) as t2
WHERE 1
AND t1.row_number in ( floor((total_rows+1)/2), floor((total_rows+2)/2) );
=end

