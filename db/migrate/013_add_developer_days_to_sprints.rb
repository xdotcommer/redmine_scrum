class AddDeveloperDaysToSprints < ActiveRecord::Migration
  def self.up
    add_column :sprints, :developer_days, :integer, :default => 0
  end

  def self.down
    remove_column :sprints, :developer_days
  end
end