class SprintAverageController < RedmineScrumController
  unloadable

  def index
    respond_to do |format|
      format.json do
        start_date = params[:since].blank? ? 3.months.ago.to_date : Date.parse(params[:since])
        render :json => SprintAverage.new().to_json
      end
    end
  end
end