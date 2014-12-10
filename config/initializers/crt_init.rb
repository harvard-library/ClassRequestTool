ROOT_URL = ENV['ROOT_URL'] || 'localhost'
ROOT_PATH = '/'
DEFAULT_MAILER_SENDER = ENV['DEFAULT_MAILER_SENDER'] || "LibraryCRT@harvard.edu"
#how many email records to pull at a time
EMAIL_BATCH_LIMIT = ENV['EMAIL_BATCH_LIMIT'].try(:to_i) || 100
HARVARD_AFFILIATES = [
  'Business School',
  'Division of Continuing Education',
  'Faculty of Arts & Sciences',
  'Graduate School of Design',
  'Graduate School of Education',
  'Kennedy School',
  'Law School',
  'School of Public Health',
  'Harvard College',
  'School of Dental Medicine',
  'Dvinity School',
  'Engineering and Applied Sciences',
  'Graduate School of Arts & Sciences',
  'Medical School',
  'Radcliffe Institute for Advanced Study',
  'Other'
]
  