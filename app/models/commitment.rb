class Commitment < ActiveRecord::Base
  unloadable
  
  belongs_to  :sprint
  belongs_to  :user
  belongs_to  :issue
  belongs_to  :estimation
  
  alias :story :issue
  alias :developer :user
  
  validates_presence_of   :sprint, :user, :issue, :estimation
  validates_uniqueness_of :issue_id, :scope => [:sprint_id, :user_id]

  before_save   :denormalize_data
  after_save    :update_story
  after_destroy :update_story
  
  delegate      :description, :to => :story
  delegate      :priority, :to => :story

  def self.from_stories(stories)
    commitments = []
    stories.each do |story|
      if story.commitment && Commitment.exists?(:sprint_id => story.sprint_id, :user_id => story.assigned_to_id, :issue_id => story.id)
        commitments << story.commitment
      else
        commitments << Commitment.new(:sprint => story.sprint, :user => story.assigned_to, :issue => story, :estimation => story.estimation, :story_points => story.estimation.value)
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
        commitment.story.save
      end
    end
  end

  def self.bulk_create(commitment_attributes)
    commitment_attributes.each do |attributes|
      commitment = new(attributes)
      unless commitment.try(:should_be_cleared?)
        commitment.save
      end
    end
  end

  def self.update_burndown_first_day(sprint_id)
    sprint = Sprint.find(sprint_id)
    Burndown::Story.snapshot_first_day(sprint)
  end
  
  def should_be_cleared?
    estimation.spiked? || ! user # || ! sprint.try(:commitable?)
  end
  
  def description=(text)
    return nil unless story
    story.description = text
  end

  def requires_clarification
    return nil unless story
    story.custom_values.find_by_custom_field_id(CustomField.find_by_name("Requires Clarification")).value
  end
  
  def requires_clarification=(value)
    return nil unless story
    story.custom_values.find_by_custom_field_id(CustomField.find_by_name("Requires Clarification")).update_attribute :value, value
  end
  
  def priority=(value)
    return nil unless story
    story.priority_id = value
  end
  
private

  def denormalize_data
    self.story_points = estimation.try(:value)
  end
  
  def update_story
    story.update_attributes(:assigned_to_id => user_id, :estimation_id => estimation_id, :sprint_id => sprint_id)
  end
end
