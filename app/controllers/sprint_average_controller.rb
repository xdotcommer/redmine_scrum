class SprintAverageController < RedmineScrumController
  unloadable

  def index

    raise SprintAverage.new(params[:since] || 3.months.ago).to_json

    respond_to do |format|
      format.json do
        render :json => SprintAverage.new(params[:since] || 3.months.ago).to_json
      end
    end
  end
end