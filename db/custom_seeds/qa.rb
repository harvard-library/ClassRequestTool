require File.join(File.dirname(__FILE__), "..", "..", "config", "environment")

PASSWORD = 'password123'
NOW = Time.now

# Set local customization
puts 'Creating customization...'
customization = Customization.new(
  :institution => 'Harvard',
  :institution_long => 'Harvard University',
  :tool_name => 'Class Request Tool',
  :slogan => "We've got cool stuff - let us show it to you",
  :tool_tech_admin_name => 'Jane Tool-Tech',
  :tool_tech_admin_email => 'jane@fas.harvard.edu',
  :notifications_on => false,
  :tool_content_admin_name => 'Rory Smithington',
  :tool_content_admin_email => 'rory@fas.harvard.edu',
  :default_email_sender => 'LibraryCRT@harvard.edu',
)
unless customization.save!
  puts 'Problem saving customization'
  exit
end

# Create user method
def create_user(index, utype)
  puts "Creating #{utype.to_s.titlecase} #{index + 1}"
  user = User.new(
    :email => "#{utype.to_s}#{index + 1}@example.com",
    :password => PASSWORD,
    :first_name => "#{utype.to_s.titlecase}-#{index + 1}",
    :last_name => "User#{index + 1}",
    :username => "#{utype.to_s}#{index + 1}",
    :patron => true
  )
  user[utype] = true
  if user.save!
    user
  else
    user.errors
  end
end

# Create 2 superadmins
puts 'Creating superamins...'
User.create(
  :email => "tim@wordsareimages.com",
  :password => PASSWORD,
  :first_name => 'Tim-Super',
  :last_name => 'Kinnel',
  :username => 'tim-admin',
  :superadmin => true
)
User.create(
  :email => "ehardman@g.harvard.edu",
  :password => PASSWORD,
  :first_name => 'Emilie-Super',
  :last_name => 'Hardman',
  :username => 'emilie-admin',
  :superadmin => true
)

# Create the patrons users (staff will be created for each repository)
puts 'Creating patrons...'
patrons = []
10.times do |i|
  patrons << create_user(i, :patron)
end

# Create default staff service
staff_service = StaffService.create(
  :description => "Pre-class appointment (required for all new requesters)"
)

# Create repositories with staff
puts 'Creating repositories...'
5.times.each do |i|
  puts "Creating Repository #{i+1}"
  repo = Repository.create(
    :name => "Repository #{i+1}",
    :description => "This is the description for Repository #{i+1}",
    :class_limit => 15
  )
  
  # Add default staff service
  puts '    Adding staff service'
  repo.staff_services << staff_service
  
  
  # Assign staff to repository
  3.times.each do |j|
    puts "    Creating Staff-#{j + 1} for Repository #{i+1}"
    repo.users << User.create(
      :email => "staff_#{i+1}_#{j + 1}@example.com",
      :password => PASSWORD,
      :first_name => "Staff-#{j + 1}",
      :last_name => "Repo#{repo.id}",
      :username => "staff#{j + 1}repo#{repo.id}",
      :staff => true
    )
  end    
end

# Create course request method
SESSION_INCR = 3.days
SECTION_INCR = 4.hours

def create_course_request(index, patron, nsections, nsessions, nstudents, duration)
  course = patron.courses.new(
    :title => "Course #{index + 1} ( Session(s): #{nsessions} | Section(s): #{nsections} )",
    :contact_first_name => patron.first_name,
    :contact_last_name => patron.last_name,
    :contact_email => patron.email,
    :contact_phone => '617-492-6666',
    :number_of_students => nstudents,
    :goal => 'Why is this required?',
    :duration => duration,
    :status => 'Active'
  )
  
  # Add default staff service
  
  # Make a few course requests homeless
  if rand(1..10) != 1
    repo_id = Repository.pluck(:id).sample
    repo = Repository.find(repo_id)
    puts "Adding repository #{repo.name}"
    course.repository = repo
  else
    puts 'Homeless course'
  end
  
  start_date = Time.now.beginning_of_day + [8, 9, 11, 13].sample.hours + [3, 7, 12, 21, 40].sample.days
  requested_dates = []
  nsessions.times do |isess|
    nsections.times do |isect|
      requested_dates[0] = start_date + (isess * SESSION_INCR)
      requested_dates[1] = requested_dates[0] + (isect * SECTION_INCR) 
      course.sections << Section.create(:session => isess + 1, :requested_dates => requested_dates)
    end
  end
  if course.save!
    course
  else
    puts 'Save error!'
    course.errors
  end
end

# Each patron creates 4 courses
# 2 requests for 1 section, 1 session
# 1 request for multiple sessions rand(2..8) - sessions scheduled 2 days apart
# 1 request for multiple sections rand(2..5)  - sections scheduled 2 hours apart
# Repository is randomized
puts 'Creating course requests...'
course_index = 1
patrons.each do |patron|
  8.times do |i|
    case i
    when 0,1
      nsections = 1
      nsessions = rand(2..8)
    when 1,2
      nsections = rand(2..5)
      nsessions = 1
     else
      nsections = 1
      nsessions = 1
   end
    
    nstudents = [5, 7, 11, 19, 23, 31].sample
    duration = [1.0, 1.5, 2.0, 2.5, 3.0].sample
    
    puts "Creating course request for #{patron.username} | sess=#{nsessions} sect=#{nsections}"
    create_course_request(course_index, patron, nsections, nsessions, nstudents, duration)
    
    course_index += 1
  end
end

puts 'Finished.'
  
    
    