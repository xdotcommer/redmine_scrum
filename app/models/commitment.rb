class Commitment < ActiveRecord::Base
  unloadable
  
  belongs_to  :sprint
  belongs_to  :user
  belongs_to  :issue
  belongs_to  :estimation
  
  alias :story :issue
  alias :developer :user
  
  validates_presence_of   :sprint, :user, :issue, :estimation
#  validates_uniqueness_of :sprint, :issue

  after_save    :update_story
  after_destroy :update_story
  
  def self.from_stories(stories)
    commitments = []
    debugger
    stories.each do |story|
      if story.commitment
        commitments << story.commitment
      else
        commitments << Commitment.new(:sprint => story.sprint, :user => story.assigned_to, :issue => story, :estimation => story.estimation)
      end
    end
    commitments
  end

  def self.bulk_update(commitment_attributes)
    commitment_attributes.each do |id, attributes|
      commitment = find(id)
      if commitment.should_be_cleared?
        commitment.destroy
      else
        commitment.update_attributes attributes
      end
    end
  end

  def self.bulk_create(commitment_attributes)
    commitment_attributes.each do |attributes|
      commitment = new(attributes)
      unless commitment.should_be_cleared?
        commitment.save
      end
    end
  end
  
  def should_be_cleared?
    estimation.spiked? || ! user # || ! sprint.try(:commitable?)
  end
  
private
  def update_story
    story.update_attributes(:assigned_to_id => user_id, :estimation_id => estimation_id, :sprint_id => sprint_id)
  end
end
