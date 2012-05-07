class AddGoalToSprints < ActiveRecord::Migration
  def self.up
    add_column :sprints, :goal, :text
  end

  def self.down
    remove_column :sprints, :goal
  end
end