class Admin::AdminController < ApplicationController

  before_filter :admins_only

  def report_form
  end
  
  def build_report
    if params[:selected_reports].blank?
      flash[:alert] = "You must select at least one report item"
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
    @custom = Customization.last
    @affiliates = Affiliate.all
    render 'admin/localize', :locals => { :custom => @custom, :affiliates => @affiliates }
  end
  
  # This sends a test email to the current user
  def send_test_email
    @delayed_jobs = Delayed::Job.all
    if 'true' == params[:queued]
      Notification.delay(:queue => 'test').test_email(current_user.email, 'queued')
    else
      Notification.test_email(current_user.email, 'unqueued').deliver
    end
    
    flash[:notice] = "You should receive an email shortly"
    redirect_to :back
  end
  
  def update_stats
    Course.update_all_stats
    flash[:notice] = 'Course stats have been updated'
    sessionless_courses = Course.where(session_count: 0).all
    sessionless_courses.each do |sc|
      flash[:alert] = flash[:alert].nil? ? '<p>Sessionless courses:</p>' : flash[:alert]
      flash[:alert] += "<p>#{sc.id} - #{sc.title}</p>\n"
    end
    flash[:alert] = flash[:alert].html_safe
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
        flash[:alert] = 'Sorry, only admins have permission to do that.'
        redirect_to '/'
      end
    end
end