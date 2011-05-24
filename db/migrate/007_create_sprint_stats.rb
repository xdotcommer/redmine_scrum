class CreateSprintStats < ActiveRecord::Migration
  def self.up
    create_table :sprint_stats do |t|
      t.column :type, :string
      t.column :sprint_id, :integer
      t.column :sprint_name, :string
      t.column :issue_status_id, :integer
      t.column :status, :string
      t.column :qa, :string
      t.column :user_id, :integer
      t.column :user_name, :string
      t.column :category_id, :integer
      t.column :category_name, :string
      t.column :current_count, :integer
      t.column :total_count, :integer
      t.column :recorded_on, :date
      t.column :journal_id, :integer
      t.column :journal_details_id, :integer
    end
  end

  def self.down
    drop_table :sprint_stats
  end
end
