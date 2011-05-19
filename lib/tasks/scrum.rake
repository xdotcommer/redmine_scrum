require 'YAML'

namespace :redmine do
  namespace :scrum do
    desc "Create Defaults (Backlog sprint, Estimations, etc.)"
    task :create_defaults => :environment do
      
      if Estimation.count == 0
        [1, 2, 3, 5, 8, 13].each do |number|
          Estimation.create(:name => number.to_s, :value => number)
        end
        Estimation.create(:name => "Spike", :value => 0)
      end

      if Sprint.count == 0
        ['Backlog', 'Icebox'].each do |name|
          Sprint.new(:name => name).save(false)
        end
      end
      
    end
    
    desc "Create sprint histories for every issue without one"
    task :create_histories => :environment do
      Issue.all.each do |issue|
        next unless issue.sprint_histories.empty?
        SprintHistory.create_from_issue issue
      end
    end
    
    desc "Update issue qa status from custom value"
    task :migrate_issues => [:create_defaults, :environment] do
      # CREATE ESTIMATIONS
      p Time.now
      
      spike = nil
      Estimation.all.each do |e|
        if e.spiked?
          spike = e
        else
          Issue.update_all "estimation_id=#{e.id}", "story_points=#{e.value}"
        end
      end
      
      Issue.update_all "estimation_id=#{spike.id}, story_points=0", "story_points=0 OR story_points IS NULL"
      
      # CREATE SPRINTS
      p Time.now
      
      existing_sprint_list = CustomField.find_by_name("Sprint").possible_values
      existing_sprint_list.each do |sprint_name|
        unless sprint_name =~ /^9999/
          unless Sprint.exists? :name => sprint_name
            end_date   = Date.parse sprint_name
            start_date = end_date - 13
            Sprint.create! :name => sprint_name, :end_date => end_date, :start_date => start_date
          end
        end
      end
      
      # MIGRATE ISSUES TO SPRINTS W/ BACKLOG_RANK, QA, ETC.
      p Time.now
      
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
      
      p Time.now
    end
  end
end