class AddClosedOnToIssues < ActiveRecord::Migration
  def self.up
    add_column :issues, :closed_on, :datetime
  end

  def self.down
    remove_column :issues, :closed_on
  end
end