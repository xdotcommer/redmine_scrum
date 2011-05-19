class CreateCommitments < ActiveRecord::Migration
  def self.up
    create_table :commitments do |t|
      t.column :sprint_id, :integer
      t.column :user_id, :integer
      t.column :issue_id, :integer
      t.column :estimation_id, :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :commitments
  end
end
