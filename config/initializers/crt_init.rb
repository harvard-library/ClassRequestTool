ROOT_URL = ENV['ROOT_URL'] || 'localhost'
ROOT_PATH = '/'
DEFAULT_MAILER_SENDER = ENV['DEFAULT_MAILER_SENDER'] || "LibraryCRT@harvard.edu"

TIME_FORMAT = "%l:%M %P"
DATE_FORMAT = "%-m/%-d/%y"

#how many email records to pull at a time
EMAIL_BATCH_LIMIT = ENV['EMAIL_BATCH_LIMIT'].try(:to_i) || 100

# Email notifications global on or off
$notifications_status = 'OFF'

# Customization
# @custom = Customization.last
# INSTITUTION           = @custom.institution
# INSTITUTION_LONG_NAME = @custom.institution_long
# TOOL_NAME             = @custom.tool_name
# TECH_ADMIN            = {
#                           name:  @custom.tool_tech_admin_name,  
#                           email: @custom.tool_tech_admin_email
#                         }
# CONTENT_ADMIN         = {
#                           name:  @custom.tool_content_admin_name,  
#                           email: @custom.tool_content_admin_email
#                         }
#                          
# AFFILIATES            = @custom.affiliates
