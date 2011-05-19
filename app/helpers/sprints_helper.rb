module SprintsHelper
  def this_sprint(sprint)
    today = Date.today
    if sprint.start_date && sprint.end_date
      today <= sprint.end_date && today >= sprint.start_date
    end
  end
end
