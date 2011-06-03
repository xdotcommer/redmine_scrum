class AddFieldsToIssues < ActiveRecord::Migration
  def self.up
    add_column :issues, :sprint_id, :integer
    add_column :issues, :estimation_id, :integer
    add_column :issues, :sprint_name, :string
    add_column :issues, :backlog_rank, :integer
    add_column :issues, :qa, :string
    add_column :issues, :qa_used_to_be, :string
    
    unless Issue.column_names.include? "story_points"
      add_column :issues, :story_points, :string
    end
  end

  def self.down
    remove_column :issues, :qa_used_to_be
    remove_column :issues, :qa
    remove_column :issues, :backlog_rank
    remove_column :issues, :sprint_name
    remove_column :issues, :estimation_id
    remove_column :issues, :sprint_id
  end
end