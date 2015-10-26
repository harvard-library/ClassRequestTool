class Admin::AdminController < ApplicationController

  require 'csv'

  before_filter :admins_only

  def report_form
    @repositories = Repository.select([:id, :name]).order("name ASC").all      # Add CSV options   
  end
  
  def csv_export
    klass = params[:klass].constantize
    
    filters = []
    params[:filters].each do |i, filter|
      unless filter.values.first['value'].blank?
        filter_string = filter.collect { |k,v| "#{k[0]}.#{v['column']}#{op(v['comparison'])}#{v['value']}" }.first
        filters << filter_string
      end
    end
    
    if klass.respond_to? :csv_data
      csv_export = CSVExport.new(klass, filters, params[:associations])
    else
      flash_message :warning, "It's not possible to export data for that."
      return_to :back
    end
        
    csv_export.build
    
    send_data csv_export.output, :type => 'text/csv', :filename => "#{params[:klass].downcase}_data_export.csv"
  end
  
  def build_report
    if params[:selected_reports].blank?
      flash_message :warning, "You must select at least one report item"
      redirect_to :back
      return
    end
    
    @report = Report.new    
    @filters = @report.build_filters(params)[:displays]
    session[:report] = @report
    @data = @report.stats(params)
  end
  
  def create_graph
    @report = session[:report]
    render :json => @report.graph(params).to_json
  end

  
  def dashboard
    @delayed_jobs = Delayed::Job.all
  end

  def harvard_colors
  end

  def localize
    @custom = Customization.first_or_create(Customization.default.attributes)
    @affiliates = Affiliate.all
    render 'admin/localize', :locals => { :custom => @custom, :affiliates => @affiliates }
  end

  # This sends a test email to the current user
  def send_test_email
    @delayed_jobs = Delayed::Job.all
    if 'true' == params[:queued]
      ::Notification.send_test_email(current_user.email, 'queued').deliver_later(:queue => 'test')
    else
      ::Notification.send_test_email(current_user.email, 'unqueued').deliver_now
    end
    
    flash_message :info, "You should receive an email shortly"
    redirect_to :back
  end
  
  def update_stats
    Course.update_all_stats
    flash_message :info, 'Course stats have been updated'
    sessionless_courses = Course.where(session_count: 0).all
    unless sessionless_courses.blank?
      sessionless_courses.each do |sc|
        sessionless_course_warning ||=  '<p>Sessionless courses:</p>'
        sessionless_course_warning += "<p>#{sc.id} - #{sc.title}</p>\n"
      end
      flash_message :warning, sessionless_course_warning.html_safe
    end 
    redirect_to :back
  end
  
  def clear_mail_queue
    if Delayed::Job.destroy_all
      render :json => { ok: true }
    else
      render :nothing
    end
  end

  private
    def admins_only
      unless current_user && (current_user.admin? || current_user.superadmin?)
        flash_message :warning, 'Sorry, only admins have permission to do that.'
        redirect_to '/'
      end
    end
    
    def op(comparison)
      case comparison
      when 'eq'
        '='
      when 'gt'
        '>'
      when 'lt'
        '<'
      when 'gte'
        '>='
      when 'lte'
        '<='
      when 'ne'
        '!='
      end
    end
end