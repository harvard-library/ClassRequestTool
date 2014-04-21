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

## Application Set-up Steps

1. Get code from: https://github.com/harvard-library/class_request_tool
2. Run bundle install. You will probably have to install OS-vendor supplied libraries to satisfy some gem install requirements.
3. Create the database and run `rake db:schema:load`, after modifying "config/database.yml" to suit your environment.
4. Create a .env file for your environment. Currently, the following variables are needed to run Class Request Tool:

```
SECRET_TOKEN=ThirtyPlusCharStringOfRandomnessGottenFromRakeSecretMaybe # Only needed in RAILS_ENV=production
DEVISE_SECRET_KEY=anotherThirtyPluscharStringOfRandomness              # Also only needed in production
ROOT_URL=my.crt.host.com
DEFAULT_MAILER_SENDER=email.address.for.mails@my.crt.host.com
EMAIL_BATCH_LIMIT=100
```

## License

This application is licensed under the GPL, version 3.
