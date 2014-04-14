ROOT_URL = ENV['ROOT_URL'] || 'localhost'
ROOT_PATH = '/'
DEFAULT_MAILER_SENDER = ENV['DEFAULT_MAILER_SENDER'] || "LibraryCRT@harvard.edu"
#how many email records to pull at a time
EMAIL_BATCH_LIMIT = ENV['EMAIL_BATCH_LIMIT'].try(:to_i) || 100
