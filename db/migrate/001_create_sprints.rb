class CreateSprints < ActiveRecord::Migration
  def self.up
    create_table :sprints do |t|
      t.column :name, :string
      t.column :version_id, :integer
      t.column :release, :string
      t.column :start_date, :date
      t.column :end_date, :date
      t.timestamps
    end
    
  end

  def self.down
    drop_table :sprints
  end
end
