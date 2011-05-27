require 'YAML'

namespace :redmine do
  namespace :scrum do
    desc "Full snapshot from issues, etc."
    task :full_snapshot => :environment do
      
      Issue.snapshot_all
      
    end
    
    desc "Update Daily Snapshots"
    task :snapshot_yesterday => :environment do
      
      Journal.create_snapshots_for_yesterday
      
    end
    
    desc "Create Defaults (Backlog sprint, Estimations, etc.)"
    task :create_defaults => :environment do
      
      Estimation.create_defaults
      Sprint.create_defaults
      
    end
    
    desc "Update issue qa status from custom value"
    task :migrate_issues => [:create_defaults, :environment] do
      # CREATE ESTIMATIONS
      Estimation.create_and_migrate
      
      # CREATE SPRINTS
      Sprint.migrate_existing
      
      # MIGRATE ISSUES TO SPRINTS W/ BACKLOG_RANK, QA, ETC.
      qa_field     = CustomField.find_by_name("QA")
      backlog_rank_field = CustomField.find_by_name("Backlog Rank")
      
      CustomField.find_by_name("Sprint").custom_values.find(:all, :conditions => {:customized_type => "Issue"}, :include => 'customized').each do |custom|
        if custom.value == "9999.99.99-ZZ-ICE"
          sprint = Sprint.find_by_name("Icebox")
        else
          sprint = Sprint.find_by_name("Backlog") unless sprint = Sprint.find_by_name(custom.value)
        end
        
        if issue = custom.customized
          issue.sprint_id   = sprint.id
          issue.sprint_name = sprint.name
          if qa = issue.custom_values.find_by_custom_field_id(qa_field.id)
            issue.qa = qa.value
          end
          if backlog_rank = issue.custom_values.find_by_custom_field_id(backlog_rank_field.id)
            issue.backlog_rank = backlog_rank.value
          end
          issue.send(:update_without_callbacks)
        end
      end
      
      # TODO: SET VERSIONS && FIX SPRINT START DATES FOR EARLY SPRINTS
      # TODO: BE SURE, WHEN REMOVING REDMINE_BACKLOGS, NOT TO REMOVE STORY_POINTS IN MIGRATION
    end
  end
end