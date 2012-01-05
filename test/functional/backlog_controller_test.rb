require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class BacklogControllerTest < ActionController::TestCase

  def setup
    Sprint.set_trackers_to_main_project
    
    issue_defaults = {
      :tracker_id  => Sprint::STORY_TRACKERS.last,
      :description => 'Some long description',
      :status      => IssueStatus.first,
      :priority    => IssuePriority.first,
      :estimation  => Estimation.first,
      :project     => Project.first,
      :author      => User.first,
      :qa          => "Needed"
    }
    
    @controller                = BacklogController.new
    @request                   = ActionController::TestRequest.new
    @response                  = ActionController::TestResponse.new
    User.current               = nil
    @request.session[:user_id] = 1
    
    @backlog                   = Sprint.find_by_name("Backlog")
    @sprint                    = Sprint.find_by_name("First Sprint")
    Issue.create! issue_defaults.merge(:subject => "I am backlog issue #1", :sprint => @backlog, :backlog_rank => 1)
    Issue.create! issue_defaults.merge(:subject => "I am backlog issue #2", :sprint => @backlog, :backlog_rank => 3)
    Issue.create! issue_defaults.merge(:subject => "I am sprint issue #1", :sprint => @sprint, :backlog_rank => 2)
    Issue.create! issue_defaults.merge(:subject => "I am sprint issue #2", :sprint => @sprint, :backlog_rank => 4)
  end
  
  def test_gets_loaded
    assert defined? BacklogController
  end
  
  def test_inherits_from_redmin_scrum_controller
    assert BacklogController.ancestors.include? RedmineScrumController
  end
  
  def test_list_backlog
    get :index, :sprint_id => @backlog.id
    assert_response :success
    assert_template 'index'
    assert assigns(:sprint) == @backlog
    assert_not_nil assigns(:stories)
  end
  
  def test_list_sprint
    get :index, :sprint_id => @sprint.id
    assert_response :success
    assert_template 'index'
    # raise assigns(:sprint).inspect
    assert assigns(:sprint) == @sprint
    assert_not_nil assigns(:stories)
  end
  
  def test_list_defaults_to_backlog
    get :index
    assert_response :success
    assert_template 'index'
    assert assigns(:sprint) == @backlog
    assert_not_nil assigns(:stories)
  end
end
