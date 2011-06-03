require 'redmine'

# Patches to the Redmine core.
require 'dispatcher'
Dispatcher.to_prepare :redmine_scrum do
  require_dependency 'issue'
  require_dependency 'issue_status'
  require_dependency 'journal'
  require_dependency 'journal_detail'
  require_dependency 'query'
  require_dependency 'redmine_scrum/hooks'

  Issue.safe_attributes "sprint_id", "estimation_id", "story_points", "sprint_name", "backlog_rank", "qa"

  # Guards against including the module multiple time (like in tests)
  # and registering multiple callbacks
  Issue.send(:include, RedmineScrum::IssuePatch) unless Issue.included_modules.include? RedmineScrum::IssuePatch
  IssueStatus.send(:include, RedmineScrum::IssueStatusPatch) unless IssueStatus.included_modules.include? RedmineScrum::IssueStatusPatch
  Query.send(:include, RedmineScrum::QueryPatch) unless Query.included_modules.include? RedmineScrum::QueryPatch
  Journal.send(:include, RedmineScrum::JournalPatch) unless Journal.included_modules.include? RedmineScrum::JournalPatch
  JournalDetail.send(:include, RedmineScrum::JournalDetailPatch) unless JournalDetail.included_modules.include? RedmineScrum::JournalDetailPatch
end

Redmine::Plugin.register :redmine_scrum do
  name 'Redmine Scrum plugin'
  author 'Michael Cowden'
  description 'This is a scrum plugin for Redmine'
  version '0.0.1'
  
  permission :sprints, {:sprints => [:index, :new, :create, :destroy, :update, :edit]}, :public => true
  permission :commitments, {:commitments => [:index, :bulk_update]}, :public => true
  menu :project_menu, :sprints, { :controller => 'sprints', :action => 'index' }, :caption => 'Sprints', :before => :issues, :param => :project_id
end
