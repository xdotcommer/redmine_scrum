class StoryAssignmentMailer < Mailer #ActionMailer::Base
  def issue_summary(issue)
    redmine_headers 'Project' => issue.project.identifier,
                    'Issue-Id' => issue.id,
                    'Issue-Author' => issue.author.login

    recipients "dev@razoo.com"
    subject "#{issue.assigned_to.try(:name)} has grabbed #{issue.tracker.try(:name)} ##{issue.id}: #{issue.subject}"
    body    :issue => issue,
            :issue_url => url_for(:controller => 'issues', :action => 'show', :id => issue)
    content_type "multipart/alternative"

    part "text/plain" do |p|
      p.body = render_message("issue_summary.text.plain.erb", body)
    end

    part "text/html" do |p|
      p.body = render_message("issue_summary.text.html.erb", body)
    end
  end
end