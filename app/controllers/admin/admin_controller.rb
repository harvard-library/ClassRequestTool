class Admin::AdminController < ApplicationController

  before_filter :admins_only

  def report_form
  end
  
  def build_report  
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
  end

  def harvard_colors
  end

  def localize
    @custom = Customization.last
    @affiliates = Affiliate.all
    render 'admin/localize', :locals => { :custom => @custom, :affiliates => @affiliates }
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

  private
    def admins_only
      unless current_user && (current_user.admin? || current_user.superadmin?)
        flash[:alert] = 'Sorry, only admins have permission to do that.'
        redirect_to '/'
      end
    end
end