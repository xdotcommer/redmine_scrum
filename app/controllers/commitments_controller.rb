class CommitmentsController < RedmineScrumController
  unloadable

  def index
    @sprint        = Sprint.find(params[:sprint_id])
    @commitments   = Commitment.from_stories(@sprint.issues.stories).sort_by {|c| c.user_id || 0 }
    @priorities    = IssuePriority.all(:order => 'position DESC')
    @unprioritized = @priorities.detect {|pr| pr.name == "Unprioritized"}
    @developers    = Role.find_by_name("Developer").members.map(&:user).select {|d| d.active? }
  end
  
  def update #don't know why bulk_update won't work - must be an engines thing
    raise params[:new_commitment_attributes].inspect
    Commitment.bulk_update(params[:commitment_attributes]) if params[:commitment_attributes]
    Commitment.bulk_create(params[:new_commitment_attributes]) if params[:new_commitment_attributes]
    Commitment.update_burndown_first_day(params[:sprint_id])

    flash[:notice] = "Commitments have been updated"
    redirect_to project_sprint_commitments_path(@project, Sprint.find_by_id(params[:sprint_id]))
  end
end