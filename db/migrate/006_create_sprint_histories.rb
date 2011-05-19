class CreateSprintHistories < ActiveRecord::Migration
  def self.up
    create_table :sprint_histories do |t|
      t.column :sprint_id, :integer
      t.column :issue_id, :integer
      t.column :tracker_id, :integer
      t.column :status_id, :string
      t.column :assigned_to_id, :integer
      t.column :author_id, :integer
      t.column :category_id, :integer
      t.column :estimation_id, :integer
      t.column :version_id, :integer
      t.column :priority_id, :integer
      t.column :qa_status, :string
      t.column :phase, :string
      t.column :developer, :string
      t.column :category_name, :string
      t.column :story_points, :integer
      t.column :status_name, :string
      t.column :tracker_name, :string
      t.column :sprint_name, :string
      t.column :version_name, :string
      t.column :priority_name, :string
      t.column :changed_by_id, :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :sprint_histories
  end
end
