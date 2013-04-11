namespace :crt do
  namespace :bootstrap do
    desc "Add the default admin"
    task :default_admin => :environment do
      user = User.new(:email => 'admin@example.com')
      if %w[development test dev local].include?(Rails.env)
        user.password = User.random_password(size = 8)
      else
        user.password = User.random_password
      end
      user.admin = true
      user.save
      puts "Admin email is: #{user.email}"
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
        #room.location = locations.sample(1)
        room.save
      end
      puts "Rooms Added!"
    end
    
    desc "run all tasks in bootstrap"
    task :run_all => [:default_admin, :default_repos, :default_locations, :default_rooms] do
      puts "Created Admin account, Repos, Locations and Rooms!"
    end
  end
end