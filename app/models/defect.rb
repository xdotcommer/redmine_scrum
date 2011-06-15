class Defect < ActiveRecord::Base
  unloadable

  acts_as_list :scope => :issue_id
  
  attr_accessible  :description

  belongs_to  :issue
end
