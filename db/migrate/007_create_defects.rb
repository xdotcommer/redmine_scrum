class CreateDefects < ActiveRecord::Migration
  def self.up
    create_table :defects do |t|
      t.column :issue_id, :integer
      t.column :status_id, :integer
      t.column :description, :text
      t.column :position, :integer
    end
  end

  def self.down
    drop_table :defects
  end
end
