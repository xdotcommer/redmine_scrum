class SprintAverageController < RedmineScrumController
  unloadable

  def index
    respond_to do |format|
      format.json do
        render :json => SprintAverage.new(Date.parse(params[:since]) || 3.months.ago.to_date).to_json
      end
    end
  end
end