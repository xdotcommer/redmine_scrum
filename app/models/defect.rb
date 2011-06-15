class Defect < ActiveRecord::Base
  unloadable

  CATEGORIES = ["Failed AC", "Bug", "Doubt", "Suggestion"]

  acts_as_list :scope => :issue_id
  
  attr_accessible  :description, :status_id, :category
  validates_presence_of   :status, :category
  
  belongs_to  :issue
  belongs_to  :status, :class_name => 'IssueStatus', :foreign_key => 'status_id'
end
