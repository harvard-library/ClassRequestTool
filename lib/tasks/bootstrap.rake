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

    desc "Add the default rooms"
    task :default_rooms => :environment do
      locations = Location.all.collect!{|x| x.id }
      ['Room A', 'Room B', 'Room C', 'Room D', 'Room E', 'Room F', 'Room G', 'Room H', 'Room I', 'Room J', 'Room K'].each do |room|
        room = Room.new(:name => room)
        room.save
      end
      puts "Rooms Added!"
    end

    desc "Add the default staff service"
    task :default_staff_service => :environment do
      repositories = Repository.all.collect!{|x| x.id }
      ['Pre-class appointment for instructor with Reference Staff (required for first time requestors, recommended for everyone)', 'Assistance with selection of materials', 'Introduction to Archives and Special Collections Research', 'Assistance with presentation of materials in class', 'Creation of sources list or research guide for course'].each do |si|
        involvement = StaffInvolvement.new(:description => si, :repository_ids => repospitories.sample(5))
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
    task :run_all => [:default_admin, :default_repos, :default_rooms, :default_staff_service, :default_attributes, :default_superadmin] do
      puts "Created Admin account, Repos, Locations and Rooms!"
    end
  end

  namespace :cron_task do
#    @per_minutes = [:send_queued_emails]
    @per_diems = [:send_homeless_notices]

    desc "Send email to admins when a class is still homeless after two days."
    task :send_homeless_notices => :environment do
      @courses = Course.where("repository_id IS NULL AND created_at <= ?", Time.now - 2.days)
      admins = User.where('admin = ? OR superadmin = ?', true, true).collect{|a| a.email + ","}
      @courses.each do |course|
        Email.create(
          :from => DEFAULT_MAILER_SENDER,
          :reply_to => DEFAULT_MAILER_SENDER,
          :to => admins.join(", "),
          :subject => "[ClassRequestTool] A Homeless class is languishing!",
          :body => "<p>A homeless class request has been waiting 2 days for processing in the Class Request Tool. A Library or Archive should offer it a home as soon as possible.</p>
          <p>
          Library/Archive: Not yet assigned<br />
          <a href='http://#{edit_course_path(course.id)}'>#{course.title}</a><br />
          Subject: #{course.subject}<br />
          Course Number: #{course.course_number}<br />
          Affiliation: #{course.affiliation}<br />
          Number of Students: #{course.number_of_students}<br />
          Syllabus: #{course.external_syllabus}<br />
          </p>
          <p>If this is appropriate for your library or archive, please <a href='http://#{edit_course_path(course.id)}'>edit the course</a> and assign it to your repository.</p>"
        )
      end
      puts "Successfully delivered homeless notices!"
    end

#     desc "Send emails that are queued up"
#     task :send_queued_emails => :environment do
#       emails = Email.to_send
#       emails.each do |email|
#         begin
#           Notification.send_queued(email).deliver
#           email.message_sent = true
#           email.date_sent = Time.now
#           email.save
#         rescue Exception => e
#           #FAIL!
#           email.error_message = e.inspect[0..4999]
#           email.to_send = false
#           email.save
#         end
#       end
#       puts "Successfully sent queued emails!"
#     end

    desc "Set up crontab"
    task :setup_crontab do
      tmp = Tempfile.new('crontab')
      tmp.write `crontab -l`.sub(/^[^\n#]*#CRT_AUTO_CRON_BEGIN.*#CRT_AUTO_CRON_END\n?/m, '')
      tmp.write "#CRT_AUTO_CRON_BEGIN\n"
      tmp.write "# Modified as of #{Time.now}\n"
      tmp.write "# This block is generated by CRT as part of deploy.\n"
      tmp.write "# Please update timestamp if you make manual alterations.\n"

      per_min_time = "*/5 * * * *"
      per_diem_time = "1 12 * * *"
      env = "RAILS_ENV=#{ENV['RAILS_ENV']}"
      preamble = "cd #{ENV['RAKE_ROOT'] || Rails.root} && #{env} #{`which rvm`.chomp} default do bundle exec #{`which rake`.chomp} crt:cron_task:"
      redirect = '> /dev/null 2>&1'

#       @per_minutes.each do |pm|
#         tmp.write "#{per_min_time} #{preamble}#{pm} #{redirect}\n"
#       end
      @per_diems.each do |pm|
        tmp.write "#{per_diem_time} #{preamble}#{pm} #{redirect}\n"
      end
      tmp.write "#CRT_AUTO_CRON_END\n"
      tmp.close
      success = system 'crontab', tmp.path
      puts 'Crontab added' if success
    end

  end
end
