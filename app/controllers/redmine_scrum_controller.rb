class RedmineScrumController < ApplicationController
  unloadable
  
  before_filter :find_project
  
protected
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