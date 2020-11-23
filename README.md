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

### Preparation
1. Clone the code from the github repository
`git clone https://github.com/harvard-library/class_request_tool`
2. Create a .env file for your environment. Copy the example text file `env-example.txt` and rename it to `.env`. Read [Environment variables](#environment-variables) and [Database configuration](#database-configuration) for more information.
3. To add your initial customizations, create a `config/customization.yml` file based on [config/customization.yml.example](config/customization.yml.example).
4. Create a mailer file `config/mailer.yml.erb` file on [config/mailer.yml.example](config/mailer.yml.example).
5. Create a `config/database.yml` file based on [config/database.yml.postgres](config/database.yml.postgres). There are no changes required to the database.yml file since it reads the environment variables in the `.env` file for the database connection.
6. Read the instructions in [Database Connection](#database-connection) to create a local database or connect to an existing remote database

### Database Connection

**Database connection options for local development**

#### Option 1 (Recommended): Create a local postgres database

* Create a local postgres database
  * This project has a database configuration in the `docker-compose-local.yml` file that can be used for local development
  * Another option is to create a database on the host machine directly
* Set the configuration values for the database name, host, port, and credentials in the `.env` file. Read [Configuration](#configuration) for more information.
* Run the rake tasks in the ruby environment
  * Open a shell in the app container to run these commands `docker exec -it crt-app bash`
  * Run `rake db:create` to create the databases for development and test environments.
  * Run `rake db:schema:load` to automatically load the schema in `./db/schema.rb`.
  * Run `rake db:seed` to seed the database.
    * *Make sure to pay attention to the output of this rake task, as it will show the random password for the superadmin user created in the database. Save the superadmin username and password in commented out lines in the `.env` file for documentation purposes only, since you will need the superadmin password to login to the application.*
  * Run `rake db:custom_seed` to load placeholder data.

##### Docker compose database container
This option is recommended when running docker compose locally. The local docker compose configuration `docker-compose-local.yml` creates a postgres database instance in a container for the application to connect to locally.

A new database will be initialized with the values in the `.env` file if it does not exist already. The postgres hostname in the `.env` configuration should match the name of the container in the docker compose configuration. The data directory in the container is mounted to a directory on the local filesystem.

  ```
  volumes:
    - ./postgresql/data:/var/lib/postgresql/data
  ```

Initialize a new database
To re-initialize a new database, delete the entire directory `./postgresql` on the host machine. Note: All data and configurations will be deleted. A new database will be initialized when the container starts if the postgres data directory is empty.

#### Option 2: Connect to an existing database

* Creating a local database is recommended when possible, in order to more safely test migrations or any changes to the data
* Connecting to an existing database on a server such as the QA database is NOT recommended when testing migrations or making any changes to the schema or the data since any issues during the development would impact the QA environment
* Update the database coniguration values in `.env` to connect to an existing database such as the QA database

### Running the app manually
These instructions are for running the application and database directly on a host.

1. Complete all steps in the [Preparation](#preparation) instructions
2. Run `bundle install`. You will probably have to install OS-vendor supplied libraries to satisfy some gem install requirements.
3. Set up the cron tasks by running `rake crt:cron_task:setup_crontab`(as the Unix user of the application)
4. Run `rake bower:install`. Note that this must be run at least once in any environment where the application or tests is going to be run, and must be re-run when JS assets included via `bower-rails` are changed. It is recommended that this be automated for deployment, as it is in the [config/deploy.rb](config/deploy.rb) that we provide here.

### Running the app with Docker Compose
These instructions are for running the application locally using docker compose. A custom image `DockerfileLocal` based on the docker ruby base image installs all required dependencies and then starts the rails application. The docker-compose file `docker-compose-local.yml` orchestrates building the image and running the container for the rails application.

#### Running the app with Docker Compose

1. Complete all steps in the [Preparation](#preparation) instructions
2. Run the docker-compose command to build the images and run the containers

  ```
  docker-compose -f docker-compose-local.yml up -d --build --force-recreate
  ```

3. Open a shell in the container
To run commands inside the container, open a shell into the container. This is only necessary to run commands inside the container, such as rails commands and rake tasks.

Example running rails commands inside the app container

  ```
  # Open a shell inside the app container
  docker exec -it crt-app bash
  # Load the schema in `./db/schema.rb`
  rake db:schema:load
  # Seed the database
  rake db:seed
  # Add new column
  rails generate migration AddMeetingLinkToSections meeting_link:text
  # Run migration
  rake db:migrate
  ```

Example running psql commands inside the postgresql container

  ```
  docker exec -it postgreshost bash
  psql -U crt_local_db_user crt_local_db
  ```

4. Stop and remove the containers

  ```
  docker-compose -f docker-compose-local.yml down
  ```

## Configuration

### Environment variables
Currently, the following variables are needed to run Class Request Tool:

  ```
  # Environment `development`, `test`, or `production`
  RAILS_ENV=development
  # Secret key required for production only
  SECRET_KEY_BASE=ThirtyPlusCharStringOfRandomnessGottenFromRakeSecretMaybe
  # A second secret key required for production only
  DEVISE_SECRET_KEY=anotherThirtyPluscharStringOfRandomness
  ROOT_URL=my.crt.host.com
  DEFAULT_MAILER_SENDER=email.address.for.mails@my.crt.host.com
  EMAIL_BATCH_LIMIT=100
  # A comma-delimited list of people who should get any email notifications when the Notifications switch is off
  OVERRIDE_RECIPIENTS=foo@bar.com,bar@foo.com
  # Database
  POSTGRES_USER=pguser
  POSTGRES_PASSWORD=password
  POSTGRES_DB=dbname
  DATABASE_URL=postgres://pguser:password@postgreshost:5432/dbname
  # Save the superadmin username and password in commented out lines for documentation purposes only
  # Superadmin USERNAME is: 'superadmin'
  # Superadmin PASSWORD is: 'password'
  ```

#### Change a user password
To change a user password from the command line, open the rails console and run a database query.

  ```
  rails console
  User.find_by(username: 'superadmin').tap {|u| u.password = 'keyboardcat'}.save!
  ```

Here is the command to set the superadmin role on an existing user.

  ```
  rails console
  User.find_by(email: 'test@example.com').tap do |me| me.superadmin = true end.save!
  ```


### Database configuration
The database username, password, and databse name must match the configuration in database.yml. The database.yml file is configured to use environment variables for the username, password, and database name. The environment variable values are set in the `.env` configuration file.

  ```
  development:
    adapter: postgresql
    encoding: unicode
    database: <%= ENV['POSTGRES_DB'] %>
    pool: 5
    username: <%= ENV['POSTGRES_USER'] %>
    password: <%= ENV['POSTGRES_PASSWORD'] %>
  ```

## Build and Deploy with Docker
The docker image is built in a local environment using the docker-compose.yml. The code and .rb configurations are copied into the image during the build. The .env file is mounted as a volume into the container from the docker server filesystem.

*Build image locally*

* Build image:
`docker-compose build`

* Push image to repository:
`docker-compose push`

* Docker server application-specific account:
`crtadm`

*Deploy image to docker server*

* Docker server docker-compose file:
`/docker/crtadm/docker/docker-compose.yml`

* Docker server .env config:
`/docker/crtadm/config/.env`

* Docker stack up:
`docker stack up --compose-file /docker/crtadm/docker/docker-compose.yml CRT-QA`

* Check on the running services:
`docker service ps CRT-QA_crt-app`

* Remove swarm stack:
`docker stack rm CRT-QA`

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
## Unusual Gems

The [Gemfile](Gemfile) contains the gem [devise_harvard_auth_proxy](https://github.com/harvard-library/devise_harvard_auth_proxy), which wraps harvard-specific login functionality.  It can safely be removed if you like, or you can leave it in, since it is not used unless a particular environment variable is defined.

## Additional Dev Notes

Additional development notes can be found [here](DEV_NOTES.md)

## Contributors

* Kathryn (Katie) Amaral: https://github.com/ktamaral
* Bobbi Fox: https://github.com/bobbi-SMR (maintainer)
* Emilie Hardman: https://github.com/emiliehardman
* Tim Kinnel: https://github.com/timmykat
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
