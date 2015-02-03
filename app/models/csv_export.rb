# If you want to export data from a class, that class must
# implement a class method called :csv_data which returns 
# the data header row, and  fields being exported in an object:
# data_obj = {
#   :fields => [],
#   :header_row => [],
#   :data => [
#       [],           row 1
#       [],           row 2
#       ...,          etc.
#   ]
# }

class CSVExport     # Don't need to inherit from ActiveRecord::Base
    
  def initialize(klass, filters)
    @klass = klass
    @filters = filters
    @data_obj = {}
    @output = []
  end
  
  def build
    header_row, sql = @klass.csv_data(@filters)

    connection = ActiveRecord::Base.connection
    result = connection.execute( sql )
    connection.close
    
    @output = CSV.generate(:encoding => 'utf-8') do |csv|
      csv << header_row
      result.each do |record|
        csv << record.values
      end
    end
  end
  
  def output
    @output
  end
end