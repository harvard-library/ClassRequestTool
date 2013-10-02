include Rails.application.routes.url_helpers

namespace :crt do
  namespace :bootstrap do
    desc "Add the default superadmin"
    task :default_superadmin => :environment do
      user = User.new(:email => 'superadmin@example.com')
      if %w[development test dev local].include?(Rails.env)
        user.password = User.random_password(size = 8)
      else
        user.password = User.random_password
      end
      user.superadmin = true
      user.save
      puts "Superadmin email is: #{user.email}"
      puts "Superadmin password is: #{user.password}"
    end
    
    desc "Add the default admin"
    task :default_admin => :environment do
      user = User.new(:email => 'admin@example.com', :username => 'admin')
      if %w[development test dev local].include?(Rails.env)
        user.password = User.random_password(size = 8)
      else
        user.password = User.random_password
      end
      user.admin = true
      user.save
      puts "Admin username is: #{user.username}"
      puts "Admin password is: #{user.password}"
    end
    
    desc "Add the default repositories"
    task :default_repos => :environment do
      ['Fine Arts', 'Houghton', 'Theatre Collection', 'Woodberry Poetry Room', 'Harvard Film Archives', 'Maps', 'Music', 'Rubel Asiatic Research Collection', 'Tozzer', 'Yenching'].each do |repo|
        repo = Repository.new(:name => repo, :description => "Default description.", :class_limit => 10)
        repo.save
      end
      puts "Repos Added!"
    end
    
    desc "Add the default locations"
    task :default_locations => :environment do
      ['Widener', 'Houghton', 'Pusey', 'Cabot', 'Law School', 'Lamont', 'Music', 'Map', 'Tozzer', 'Film', 'Fine Arts'].each do |location|
        location = Location.new(:name => location)
        location.save
      end
      puts "Locations Added!"
    end
    
    desc "Add the default rooms"
    task :default_rooms => :environment do
      locations = Location.all.collect!{|x| x.id }
      ['Room A', 'Room B', 'Room C', 'Room D', 'Room E', 'Room F', 'Room G', 'Room H', 'Room I', 'Room J', 'Room K'].each do |room|
        room = Room.new(:name => room, :location_id => locations.sample(1)[0].to_i)
        room.save
      end
      puts "Rooms Added!"
    end
    
    desc "Add the default staff involvement"
    task :default_staff_involvement => :environment do
      repospitories = Repository.all.collect!{|x| x.id }
      ['Pre-class appointment for instructor with Reference Staff (required for first time requestors, recommended for everyone)', 'Assistance with selection of materials', 'Introduction to Archives and Special Collections Research', 'Assistance with presentation of materials in class', 'Creation of sources list or research guide for course'].each do |si|
        involvement = StaffInvolvement.new(:involvement_text => si, :repository_ids => repospitories.sample(5))
        involvement.save
      end
      puts "Staff Involvements Added!"
    end
    
    desc "Add the default attributes"
    task :default_attributes => :environment do
      repospitories = Repository.all.collect!{|x| x.id }
      rooms = Room.all.collect!{|x| x.id }
      ['Stained Glass Window', 'Computer and data projector', 'Wifi', 'Document Camera', 'MondoPad (55\" iPad for the wall.Widener only)', 'VHS video player', 'DVD player', 'CD audio player', 'Cassette player', '35 mm slide projector', 'Overhead transparency projection'].each do |a|
        attribute = ItemAttribute.new(:name => a, :repository_ids => repospitories.sample(5), :room_ids => rooms.sample(5))
        attribute.save
      end
      puts "Item Attributes Added!"
    end
    
    desc "run all tasks in bootstrap"
    task :run_all => [:default_admin, :default_repos, :default_locations, :default_rooms, :default_staff_involvement, :default_attributes, :default_superadmin] do
      puts "Created Admin account, Repos, Locations and Rooms!"
    end
  end
  
  namespace :cron_task do
    desc "Send email to admins when a class is still homeless after two days."
    task :send_homeless_notices => :environment do
      @courses = Course.find(:all, :conditions => ['repository_id IS NULL AND created_at <= ?', Time.now - 2.days])
      @courses.each do |course|
        admins = ""
        User.all(:conditions => {:admin => true}).collect{|a| admins = a.email + ","}
        Email.create(
          :from => DEFAULT_MAILER_SENDER,
          :reply_to => DEFAULT_MAILER_SENDER,
          :to => admins,
          :subject => "[ClassRequestTool] A Homeless class is languishing!",
          :body => "<p>A homeless class request has been waiting for 2 days now in the Class Request Tool. A Library or Archive should claim it as soon as possible.</p></p> <p>See the details below.</p><p>If this is appropriate for your library or archive, <a href='#{ROOT_URL}#{edit_course_path(course.id)}'>edit the course</a> to reflect its new location.</p>"
        )
      end
      puts "Successfully delivered homeless notices!"
    end
    
    # desc "Automatically close classes when date has been reached."
    # task :close_classes => :environment do
    #   @courses = Course.find(:all, :conditions => ['status IS NOT "Closed" AND timeframe < ?', Time.now])
    #   @courses.each do |course|
    #     course.status = "Closed"
    #     course.save
    #   end
    #   puts "Successfully changed couses statuses"
    # end
    
    desc "Send emails that are queued up"
    task :send_queued_emails => :environment do
      emails = Email.to_send
      emails.each do |email|
        begin
          Notification.send_queued(email).deliver
          email.message_sent = true
          email.date_sent = Time.now
          email.save
        rescue Exception => e
          #FAIL!
          email.error_message = e.inspect[0..4999]
          email.to_send = false
          email.save
        end
      end  
      puts "Successfully sent queued emails!" 
    end
    
    desc "run all tasks in cron_task"
    task :run_all => [:send_homeless_notices, :send_queued_emails] do
      puts "Sent all notices!"
    end
    
  end
end