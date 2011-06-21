class DefectsController < RedmineScrumController
  unloadable
  
  def update
    raise "HERE"
    @defect = Defect.find(params[:defect][:id])
    @defect.update_attributes(params[:defect])
    redirect_to @defect.issue
  end
  
  def destroy
    @defect = Defect.find(params[:id])
    @defect.destroy
    redirect_to @defect.issue
  end
end
