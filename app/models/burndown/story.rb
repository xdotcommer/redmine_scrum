class Burndown::Story < Burndown
  unloadable
  
  def self.snapshot_users_for(sprint, snapshot_date)
    sprint.issues.stories.group_by {|i| i.assigned_to_id}.each do |user_id, issues|

      unless snapshot = find_by_date_and_sprint_id_and_user_id(snapshot_date, sprint.id, user_id)
        snapshot = new(:date => snapshot_date, :sprint_id => sprint.id, :sprint_name => sprint.name, :user_id => user_id, :user_name => User.find(user_id).login)
      end
      
      FIELD_PREFIXES.each do |prefix|
        snapshot.send(:"#{prefix}_count=", issues.select {|i| i.status_id == status_id_for_prefix(prefix) }.size)
        snapshot.send(:"#{prefix}_point_count=", issues.inject(0) {|sum, i| sum += (i.status_id == status_id_for_prefix(prefix)) ?  i.story_points : 0 } )
      end

      snapshot.committed_count       = Commitment.count(:conditions => ["user_id=? AND sprint_id=?", user_id, sprint.id])
      snapshot.committed_point_count = Commitment.sum(:story_points, :conditions => ["user_id=? AND sprint_id=?", user_id, sprint.id])

      snapshot.save!
    end
  end
end