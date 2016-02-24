ROOT_URL = ENV['ROOT_URL'] || 'localhost'
ROOT_PATH = '/'
DEFAULT_MAILER_SENDER = ENV['DEFAULT_MAILER_SENDER'] || "LibraryCRT@harvard.edu"
#how many email records to pull at a time
EMAIL_BATCH_LIMIT = ENV['EMAIL_BATCH_LIMIT'].try(:to_i) || 100
TIME_FORMAT = ENV['TIME_FORMAT'] || "%l:%M %P"      # 3:45 pm
DATE_FORMAT = ENV['DATE_FORMAT'] ||  "%b %-d, %Y"    # Jan 1, 2015

DATETIME_FORMAT =         "#{DATE_FORMAT} #{TIME_FORMAT}"
DATETIME_2_LINE_FORMAT =  "#{DATE_FORMAT}<br />#{TIME_FORMAT}"  # Requires .html_safe
DATETIME_AT_FORMAT =      "#{DATE_FORMAT} @ #{TIME_FORMAT}"
DATETIME_AEON_FORMAT =    "%m/%d/%Y %I:%M %P"
