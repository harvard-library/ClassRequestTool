# Class Request Tool

## Description

The Class Request Tool (CRT) is a class reservation system that lets instructors request assistance, space, and time for teaching at all archives and special collections repositories within an institution. Facing both patrons and staff, it is intended to centralize the management of class requests in order to reduce the burden of communication and improve patron access.

* Handles booking classes from start to finish, while keeping a traceable record of interactions
  1. Accepts requests via authenticated form
  2. Routes requests to relevant administrators
  3. Handles scheduling of classes
  4. Sends out post-class assessment to instructors (Optional)
* Supports managing multiple repositories
  * Patrons can request a class at a specific repository, or defer that decision to administrators
  * Individual portal pages allow for per-repository display customization
  * Repositories can define and display individualized policies
* Interacts with Atlas Systems' [Aeon] (https://www.atlas-sys.com/aeon/ "Aeon") circulation system for special collections
* Collects data for assessment and reporting

## System Requirements

### General
* Ruby 2.1.X or higher
* Bundler
* [NodeJS](http://nodejs.org/) (for assets compilation and running Bower)
* [Bower](http://bower.io/)
* [ImageMagick](http://imagemagick.org/)
* A webserver capable of interfacing with Rails applications.  Ideally, Apache or Nginx with mod_passenger
* Linux/OSX.  Windows will probably work fine, but we don't test on Windows as of now.

## Application Set-up Steps

1. Get code from: https://github.com/harvard-library/class_request_tool
2. Run bundle install. You will probably have to install OS-vendor supplied libraries to satisfy some gem install requirements.
3. Create the database and create a config/database.yml file modeled on  "[config/database.yml.postgres](config/database.yml.postgres)" to suit your environment.
4. Run `rake db:schema:load`.
5. Create a .env file for your environment. Currently, the following variables are needed to run Class Request Tool:

  ```
  SECRET_KEY_BASE=ThirtyPlusCharStringOfRandomnessGottenFromRakeSecretMaybe # Only needed in RAILS_ENV=production
  DEVISE_SECRET_KEY=anotherThirtyPluscharStringOfRandomness              # Also only needed in production
  ROOT_URL=my.crt.host.com
  DEFAULT_MAILER_SENDER=email.address.for.mails@my.crt.host.com
  EMAIL_BATCH_LIMIT=100
  OVERRIDE_RECIPIENTS=foo@bar.com,bar@foo.com                    # a comma-delimited list of people who should get any email notifications when the Notifications switch is off
  ```
6. To add your initial customizations, create a `config/customization.yml` file based on [config/customization.yml.example](config/customization.yml.example), and a `config/mailer.yml` file based on [config/mailer.yml.example](config/mailer.yml.example).

7. Run:
   ```Shell
    rake db:seed
   ```
Make sure you pay attention to the output of this rake task, as it will give you a random password for the Superadmin user created in the database.

8. Set up the cron tasks by running (as the Unix user of the application)
   ```Shell
    rake crt:cron_task:setup_crontab
   ```

9. Run `rake bower:install`. Note that this must be run at least once in any environment where the application or tests is going to be run, and must be re-run when JS assets included via `bower-rails` are changed.  
 It is recommended that this be automated for deployment, as it is in the  [config/deploy.rb](config/deploy.rb) that we provide here.

## Capistrano

Deployment is beyond the scope of this README, and generally site-specific. We provide a [config/deploy.rb](config/deploy.rb), as well as stage `.example` files that reflect deployment practice at Harvard.

Some basic notes:
* The example files are written with this environment in mind:
  * Bundler
  * Capistrano 3+
  * A user install of RVM for ruby management
* Arbitrary rake tasks can be run remotely via the `deploy:rrake` task. Syntax is `cap $STAGE deploy:rrake T=$RAKE_TASK`.  So, to run `rake db:seed` in the `qa` deploy environment, do:

  ```Shell
  cap qa deploy:rrake T=db:seed
  ```

## Additional Dev Notes

Additional development notes can be found [here](DEV_NOTES.md)

## Contributors

* Bobbi Fox: https://github.com/bobbi-SMR (maintainer)
* Tim Kinnel: https://github.com/timmykat
* Emilie Hardman: https://github.com/emiliehardman
* Dave Mayo: https://github.com/pobocks
* Anita Patel: http://github.com/apatel

## Supporting Institutions

This tool was developed with the generous support of:
* The [Arcadia Fund](http://www.arcadiafund.org.uk/)
* [Berkman Center for Internet & Society](http://cyber.law.harvard.edu/)
* [Harvard Library Lab](http://lab.library.harvard.edu/)
* [Harvard Library Technology Services](http://huit.harvard.edu/services/library-technology-services)
* [Houghton Library](http://hcl.harvard.edu/libraries/houghton/)

## License and Copyright

This application is licensed under the GPL, version 3.

2011 President and Fellows of Harvard College



