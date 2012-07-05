class RedmineScrumController < ApplicationController
  unloadable
  
  before_filter :find_project
  
protected
  def setup_sprints
    @sprints = Sprint.commitable
    if params[:new_sprint_id]
      @sprint = params[:new_sprint_id] ? Sprint.find(params[:new_sprint_id]) : Sprint.current
    else
      @sprint = params[:sprint_id] ? Sprint.find(params[:sprint_id]) : Sprint.current
    end
    @sprint = Sprint.last unless @sprint
  end

  def find_project
    if params[:project]
      @project = Project.find params[:project]
    elsif params[:project_id]
      @project = Project.find params[:project_id]
    else
      @project = Project.first
    end
  end
end