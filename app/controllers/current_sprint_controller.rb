class CurrentSprintController < RedmineScrumController
  unloadable

  def index
    respond_to do |format|
      format.json do
        render :json => Sprint.current || Sprint.last
      end
    end
  end
end