class WelcomeController < ApplicationController
  before_action :authenticate_admin_or_staff!, :only => [:dashboard]
  before_action :prevent_caching, :only => [:show]

  def show
    @repositories = Repository.order(:name)
    @courses = Course.with_status('Closed').past.limit(5).order_by_last_date
    @featured_image = AttachedImage.where(:featured => true, :picture_type => 'Repository').sample
    if @featured_image.blank?
      @featured_image = AttachedImage.new
      @featured_image.caption = "No image available"
    else
      @featured_repository = @featured_image.owner
    end
  end

  def healthcheck
    render plain: "healthcheck"
  end

  private
    def prevent_caching
      response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    end

end
