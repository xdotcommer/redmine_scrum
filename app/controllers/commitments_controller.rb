class CommitmentsController < RedmineScrumController
  unloadable

  def index
    @sprint        = Sprint.find(params[:sprint_id])
    @commitments   = Commitment.from_stories(@sprint.issues.stories).sort_by {|c| c.user_id || 0 }
    @priorities    = IssuePriority.all(:order => 'position DESC')
    @unprioritized = @priorities.detect {|pr| pr.name == "Unprioritized"}
    @developers    = Role.find_by_name("Developer").members.map(&:user).select {|d| d.active? }
  end
  
  def update
    Commitment.rebuild(params[:sprint][:new_commitment_attributes], params[:sprint][:commitment_attributes])
    Commitment.update_burndown_first_day(params[:sprint_id])
    
    flash[:notice] = "Commitments have been updated"
    redirect_to project_sprint_commitments_path(@project, Sprint.find_by_id(params[:sprint_id]))
  end
end