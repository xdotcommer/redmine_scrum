class AddOtherStatsToSprints < ActiveRecord::Migration
  def self.up
    add_column :sprints, :bugs, :integer, :default => 0
    add_column :sprints, :defects, :integer, :default => 0
    add_column :sprints, :reopens, :integer, :default => 0
    add_column :sprints, :distractions, :integer, :default => 0
  end

  def self.down
    remove_column :sprints, :bugs
    remove_column :sprints, :defects
    remove_column :sprints, :reopens
    remove_column :sprints, :distractions
  end
end