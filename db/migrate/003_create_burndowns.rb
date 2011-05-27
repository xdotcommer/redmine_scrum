class CreateBurndowns < ActiveRecord::Migration
  def self.up
    create_table :burndowns do |t|
      t.column :type, :string
      t.column :date, :date
      t.column :sprint_id, :integer
      t.column :sprint_name, :string
      t.column :user_id, :integer
      t.column :user_name, :string
      t.column :open_count, :integer, :default => 0
      t.column :open_point_count, :integer, :default => 0
      t.column :pending_count, :integer, :default => 0
      t.column :pending_point_count, :integer, :default => 0
      t.column :invalid_count, :integer, :default => 0
      t.column :invalid_point_count, :integer, :default => 0
      t.column :complete_count, :integer, :default => 0
      t.column :complete_point_count, :integer, :default => 0
      t.column :verified_count, :integer, :default => 0
      t.column :verified_point_count, :integer, :default => 0
      t.column :duplicate_count, :integer, :default => 0
      t.column :duplicate_point_count, :integer, :default => 0
      t.column :wont_count, :integer, :default => 0
      t.column :wont_point_count, :integer, :default => 0
      t.column :reopened_count, :integer, :default => 0
      t.column :reopened_point_count, :integer, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :burndowns
  end
end
