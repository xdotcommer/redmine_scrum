class CommitmentsController < RedmineScrumController
  unloadable

  def index
    @sprint      = Sprint.find(params[:sprint_id])
    @commitments = Commitment.from_stories(@sprint.issues.stories)
  end
  
  def update #don't know why bulk_update won't work - must be an engines thing
    Commitment.bulk_update(params[:commitment_attributes]) if params[:commitment_attributes]
    Commitment.bulk_create(params[:new_commitment_attributes]) if params[:new_commitment_attributes]
    Commitment.update_burndown_first_day(params[:sprint_id])

    flash[:notice] = "Commitments have been updated"
    redirect_to project_sprint_commitments_path(@project, Sprint.find_by_id(params[:sprint_id]))
  end
end