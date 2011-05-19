class CreateEstimations < ActiveRecord::Migration
  def self.up
    create_table :estimations do |t|
      t.column :name, :string
      t.column :value, :integer
    end
  end

  def self.down
    drop_table :estimations
  end
end
