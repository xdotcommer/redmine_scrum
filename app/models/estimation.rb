class Estimation < ActiveRecord::Base
  unloadable
  
  has_many  :issues
  has_many  :commitments

  def self.spike
    find_by_value(0)
  end

  def self.create_defaults
    if count == 0
      [1, 2, 3, 5, 8, 13].each do |number|
        create(:name => number.to_s, :value => number)
      end
      create(:name => "Spike", :value => 0)
    end
  end

  def self.create_and_migrate
    spike = nil
    
    all.each do |e|
      if e.spiked?
        spike = e
      else
        Issue.update_all "estimation_id=#{e.id}", "story_points=#{e.value}"
      end
    end
    
    Issue.update_all "estimation_id=#{spike.id}, story_points=0", "story_points=0 OR story_points IS NULL"
  end
  
  def spiked?
    value == 0
  end
end
