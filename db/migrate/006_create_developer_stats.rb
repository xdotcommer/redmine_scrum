class CreateDeveloperStats < ActiveRecord::Migration
  def self.up
    create_table :developer_stats do |t|
      t.column :sprint_id, :integer, :null => false
      t.column :sprint_name, :string, :null => false
      t.column :user_id, :integer, :null => false
      t.column :user_name, :string, :null => false
      t.column :committed_stories, :integer, :default => 0
      t.column :committed_points, :integer, :default => 0
      t.column :completed_stories, :integer, :default => 0
      t.column :completed_points, :integer, :default => 0
      t.column :carryover_stories, :integer, :default => 0
      t.column :carryover_points, :integer, :default => 0
      t.column :pending_story_submissions, :integer, :default => 0
      t.column :story_reopens, :integer, :default => 0
      t.column :days_until_first_story_pending, :integer, :default => 0
      t.column :days_until_first_story_complete, :integer, :default => 0
      t.timestamp
    end
  end

  def self.down
    drop_table :developer_stats
  end
end
