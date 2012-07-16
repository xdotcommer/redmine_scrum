class AddCommitmentsToSprints < ActiveRecord::Migration
  def self.up
    add_column :sprints, :committed_points, :integer, :default => 0
    add_column :sprints, :committed_stories, :integer, :default => 0
    add_column :sprints, :completed_points, :integer, :default => 0
    add_column :sprints, :completed_stories, :integer, :default => 0
    add_column :sprints, :pending_points, :integer, :default => 0
    add_column :sprints, :pending_stories, :integer, :default => 0
  end

  def self.down
    remove_column :sprints, :committed_points
    remove_column :sprints, :committed_stories
    remove_column :sprints, :completed_points
    remove_column :sprints, :completed_stories
    remove_column :sprints, :pending_points
    remove_column :sprints, :pending_stories
  end
end