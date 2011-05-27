class Burndown::Story < Burndown
  unloadable
  
  def self.log(date, sprint, user)
    if snapshot = find_by_date_and_sprint_id_and_user_id(date, sprint.id, user.id)
    else
      snapshot = new(:date => date, :sprint_id => sprint.id, :sprint_name => sprint.name, :user_id => user.id, :user_name => user.login)
    end
    
    issues = Issue.find(:all, :conditions => {:assigned_to_id => user.id, :sprint_id => sprint.id, :tracker_id => Sprint::STORY_TRACKERS})

    FIELD_PREFIXES.each do |prefix|
      snapshot.send(:"#{prefix}_count=", issues.select {|i| i.status_id == status_id_for_prefix(prefix) }.size)
      snapshot.send(:"#{prefix}_point_count=", issues.inject(0) {|sum, i| sum += (i.status_id == status_id_for_prefix(prefix)) ?  i.story_points : 0 } )
    end

    raise snapshot.inspect
  end
end