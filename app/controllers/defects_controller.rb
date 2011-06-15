class DefectsController < RedmineScrumController
  unloadable
  
  def update
    @defect = Defect.find(params[:defect][:id])
    @defect.update_attribute(:description, params[:defect][:description])
    redirect_to @defect.issue
  end
  
  def destroy
    @defect = Defect.find(params[:id])
    @defect.destroy
    redirect_to @defect.issue
  end
end
