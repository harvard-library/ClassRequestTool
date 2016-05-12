# Basic file for seeding the database

# Create a default superadmin user
pw =  if %w[development test dev local].include?(Rails.env)
        User.random_password(size = 8)
      else
        User.random_password
      end 
User.create(
  :username               => 'superadmin',
  :password               => pw,
  :password_confirmation  => pw,
  :email                  => 'superadmin@example.edu',
  :first_name             => 'Super',
  :last_name              => 'Admin',
  :superadmin             => true
)
puts "Superadmin USERNAME is: 'superadmin'"
puts "Superadmin PASSWORD is: '#{pw}'"
