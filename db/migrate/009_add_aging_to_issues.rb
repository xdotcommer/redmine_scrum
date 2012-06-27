class AddAgingToIssues < ActiveRecord::Migration
  def self.up
    add_column :issues, :opened_on, :datetime
  end

  def self.down
    remove_column :issues, :opened_on
  end
end