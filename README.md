# Class Request Tool

## Description

The Class Request Tool (CRT) is a class reservation system that lets instructors request assistance, space, and time for teaching at all archives and special collections repositories within an institution. Facing both patrons and staff, it is intended to centralize the management of class requests in order to reduce the burden of communication and improve patron access.

* Handles booking classes from start to finish, while keeping a traceable record of interactions
  1. Accepts requests via authenticated form
  2. Routes requests to relevant administrators
  3. Handles scheduling of classes
  4. Sends out post-class assessment to instructors (Optional)
* Supports managing multiple respositories
  * Patrons can request a class at a specific repository, or defer that decision to administrators
  * Individual portal pages allow for per-repository display customization
  * Repositories can define and display individualized policies
* Interacts with Atlas Systems' [Aeon] (https://www.atlas-sys.com/aeon/ "Aeon") circulation system for special collections
* Collects data for assessment and reporting

## System Requirements

### General
* Ruby 2.1.X or higher
* Bundler
* NodeJS (for assets compilation and running Bower
* Bower (non-global installs are fine, regardless of what error messages might say)
* [ImageMagick](http://imagemagick.org/)
* A webserver capable of interfacing with Rails applications.  Ideally, Apache or Nginx with mod_passenger
* Linux/OSX.  Windows will probably work fine, but we don't test on Windows as of now.

## Application Set-up Steps

1. Get code from: https://github.com/harvard-library/class_request_tool
2. Run bundle install. You will probably have to install OS-vendor supplied libraries to satisfy some gem install requirements.
3. Create the database and run `rake db:schema:load`, after modifying "config/database.yml" to suit your environment.
4. Create a .env file for your environment. Currently, the following variables are needed to run Class Request Tool:

  ```
  SECRET_KEY_BASE=ThirtyPlusCharStringOfRandomnessGottenFromRakeSecretMaybe # Only needed in RAILS_ENV=production
  DEVISE_SECRET_KEY=anotherThirtyPluscharStringOfRandomness              # Also only needed in production
  ROOT_URL=my.crt.host.com
  DEFAULT_MAILER_SENDER=email.address.for.mails@my.crt.host.com
  EMAIL_BATCH_LIMIT=100
  ```
5. Run bootstrap rake tasks:

  ```Shell
   rake crt:bootstrap:run_all
  ```
6. Set up cron jobs to run various tasks, detailed in [lib/tasks/bootstrap.rb](lib/tasks/bootstrap.rb)
7. Run `rake bower:install`. Note that this must be run at least once in any environment where the application or tests is going to be run, and must be re-run when JS assets included via `bower-rails` are changed.  It is recommended that this be automated for deployment.

## Capistrano

Deployment is beyond the scope of this README, and generally site-specific.  There are example capistrano deployment files that reflect deployment practice at Harvard.

Some basic notes:
* The example files are written with this environment in mind:
  * Capistrano 3+
  * A user install of RVM for ruby management
* Arbitrary rake tasks can be run remotely via the `deploy:rrake` task. Syntax is `cap $STAGE deploy:rrake T=$RAKE_TASK`.  So, to run `rake crt:bootstrap` in the `qa` deploy environment, do:

  ```Shell
  cap qa deploy:rrake T=crt:bootstrap
  ```

## Additional Dev Notes

Additional development notes can be found [here](DEV_NOTES.md)

## Contributors

* Bobbi Fox: http://github.com/bobbi-SMR
* Dave Mayo: http://github.com/pobocks (primary contact)
* Anita Patel: http://github.com/apatel

## License and Copyright

This application is licensed under the GPL, version 3.

2011 President and Fellows of Harvard College



> Written with [StackEdit](https://stackedit.io/).
