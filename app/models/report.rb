# Since we don't need to persist the reports, we don't inherit from ActiveRecord::Base
class Report

  attr_accessor :report_filters
  
  # Builds the filter
  def build_filters(params)
    @report_filters = {
      :clauses => [],
      :displays => []
    }
    if params[:closed_only]
      @report_filters[:clauses] << "status='Closed'"
      @report_filters[:displays] << "Only closed classes"
    else
      @report_filters[:clauses] << "status!='Cancelled'"
      @report_filters[:displays] << "Active and closed classes (all except cancelled)"
   end
    
    unless params[:repo].blank?
      repo = Repository.find(params[:repo].to_i)
      @report_filters[:clauses] << "repository_id=#{params[:repo]}"
      @report_filters[:displays] << "For #{repo.name} only"    
    end
    
    unless params[:affiliate].blank?
      @report_filters[:clauses] << "affiliation='#{params[:affiliate]}'"
      @report_filters[:displays] << "Requests from #{params[:affiliate]} only"
    end
    
    unless params[:start_date].blank? || params[:end_date].blank?
      start_date = to_time_format(params[:start_date])
      end_date = to_time_format(params[:end_date])
      unless end_date.to_time < start_date.to_time
        @report_filters[:clauses] << "created_at <@ tsrange('#{start_date}','#{end_date}')"
        @report_filters[:displays] << "Request created between <b>#{params[:start_date]}</b> and <b>#{params[:end_date]}</b>"
      end    
    end
    @report_filters
  end
  
  # The params specify what data to include
  def stats(params)
    output = {}
    params[:selected_reports].keys.each do |report|
      report = report.to_sym
      options = Rails.configuration.crt_reports[report]
      if 'stat' == options['type']
        where_clause = @report_filters[:clauses].clone
        unless options['where'].blank?
          where_clause << options['where']
        end
        sql = "#{options['select']} WHERE #{where_clause.join(' AND ')} #{options['group_by']} #{options['order_by']} #{options['limit']}"
        result = do_query(sql)
        output[report] = []
        result.each do |row|
          output[report] << row
        end
      elsif 'graph' == options['type']
        output[report] = 'Loading via AJAX'
      end
    end
    output
  end
  
  def graph(params)
    graph = Rails.configuration.crt_reports[params[:id].to_sym]
    where_clause = @report_filters[:clauses].clone unless 'ignore' == graph['where']
    output = {}
    output['id'] = params[:id]
#   sql = "#{graph['select']} #{graph['group_by']} #{graph['order_by']} #{graph['limit']}"
    sql = graph['select']
    sql += ('ignore' == graph['where']) ? '' : " WHERE #{where_clause.join(' AND ')}" 
    sql += " #{graph['group_by']} #{graph['order_by']} #{graph['limit']}"
    
    data_hash = {}
    data_hash['series'] = []
    scatter_plot = ['scatter', 'bubble'].include? graph['highchart_options']['chart']['type']
    if scatter_plot
      datapoint_keys = graph['data_model']['series'][0]['data']
    end    
    if graph['data_model']['categories']
      data_hash['categories'] = []
      category_key = graph['data_model']['categories']
    end
    result = do_query(sql)
    result.each do |row|
      if category_key
        data_hash['categories'] << row[category_key]
      end
      graph['data_model']['series'].each_with_index do |series, i|
        if data_hash['series'][i].nil?            
          data_hash['series'][i] = {
            'name' => graph['data_model']['series'][i]['name'],
            'data' => []
          }
        end

        if scatter_plot
          data_hash['series'][i]['data'] << [ row[datapoint_keys['x']].to_i, row[datapoint_keys['y']].to_i, row[datapoint_keys['z']].to_i ]
        else 
          series_key = graph['data_model']['series'][i]['data']['y']
          data_hash['series'][i]['data'] << row[series_key].to_i
        end
      end
    end
    
    data_hash = sort_multiseries(data_hash) if (!scatter_plot && data_hash['series'].length > 1)

    output['options'] = build_highcharts_options(data_hash, graph['highchart_options'])
    output
  end
  
  # This method will sort the data hash based on a vertical sum of the series data
  def sort_multiseries(data_hash)
    series_column_sum = []
    series_column_sum.fill(0,0,data_hash['categories'].length)
    data_hash['series'].each do |series|
      series['data'].each_with_index do |v, i|
        series_column_sum[i] += v
      end
    end
    sorted_indices = series_column_sum.each_with_index.map { |x, i| [x,i] }.sort_by{ |x| x[0] }.reverse.map{ |x| x[1] }
    data_hash['categories'] = sort_like_source(sorted_indices, data_hash['categories'])
    data_hash['series'].each_with_index do |series, i|
      data_hash['series'][i]['data'] = sort_like_source(sorted_indices, data_hash['series'][i]['data'])
    end
    data_hash
  end
  
  def sort_like_source(source_array, array)
    new_array = []
    source_array.each do |x|
      new_array << array[x]
    end
    new_array
  end

  def build_highcharts_options(data, options)
    if data['categories']
      options['xAxis']['categories'] = data['categories'].clone
    end
    options['series'] = data['series'].clone
    options
  end
    
  def do_query(sql)
    connection = ActiveRecord::Base.connection
    result = connection.execute( sql )
    connection.close
    result
  end
    
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end
  
private
  def to_time_format(string)
    unless /\d{1,2}\/\d{1,2}\/\d{2,4}/.match(string)
      raise 'Format of the string must be ##/##/####'
      return
    end
    x = string.split('/')
    "#{x[2]}-#{x[0]}-#{x[1]}"
  end
end
