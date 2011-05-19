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
      # MIGRATE BACKLOG RANKS
      p Time.now
      
      backlog_rank = CustomField.find_by_name("Backlog Rank")
      CustomValue.find(:all, :include => [:customized], :conditions => {:customized_type => "Issue", :custom_field_id => backlog_rank.id}).each do |custom_value|
        issue              = custom_value.customized
        issue.backlog_rank = custom_value.value
        issue.send(:update_without_callbacks)
      end
      
      CustomField.find_by_name("Backlog Rank").custom_values.find(:all, :conditions => {:customized_type => "Issue"}, :include => 'customized').each do |custom|
        custom.customized.update_attribute(:backlog_rank, custom.value)
      end
      
      MIGRATE STORY POINT - ESTIMATIONS
      p Time.now

      spike = nil
      Estimation.all.each do |e|
        if e.spiked?
          spike = e ; next
        end
        
        Issue.update_all "estimation_id=#{e.id}", "story_points=#{e.value}"
      end
      
      Issue.update_all "estimation_id=#{spike.id}, story_points=0", "story_points=0 OR story_points IS NULL"
      
      # TODO: BE SURE, WHEN REMOVING REDMINE_BACKLOGS, NOT TO REMOVE STORY_POINTS IN MIGRATION
      
      # MIGRATE QA STATUSES
      p Time.now
      
      CustomField.find_by_name("QA").custom_values.find(:all, :conditions => {:customized_type => "Issue"}, :include => 'customized').each do |custom|
        custom.customized.update_attribute(:qa, custom.value)
      end
      
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
      
      # MIGRATE ISSUES TO SPRINTS
      p Time.now
      
      CustomField.find_by_name("Sprint").custom_values.find(:all, :conditions => {:customized_type => "Issue"}, :include => 'customized').each do |custom|
        if custom.value == "9999.99.99-ZZ-ICE"
          sprint = Sprint.find_by_name("Icebox")
        else
          sprint = Sprint.find_by_name("Backlog") unless sprint = Sprint.find_by_name(custom.value)
        end
        
        if issue = custom.customized
          issue.sprint_id   = sprint.id
          issue.sprint_name = sprint.name
          issue.send(:update_without_callbacks)
        end
      end
      
      # TODO: SET VERSIONS && FIX SPRINT START DATES FOR EARLY SPRINTS
      
      p Time.now
    end
  end
end