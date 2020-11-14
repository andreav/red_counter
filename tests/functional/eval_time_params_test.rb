require File.expand_path('../../test_helper', __FILE__)
require_relative '../test_utils'

class EvalTimeParamsTest < ActionController::TestCase
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :issues,
           :issue_statuses,
           :versions,
           :trackers,
           :projects_trackers,
           :issue_categories,
           :enabled_modules,
           :enumerations,
           :attachments,
           :workflows,
           :custom_fields,
           :custom_values,
           :custom_fields_projects,
           :custom_fields_trackers,
           :time_entries

  # RedCounter::TestCase.create_fixtures(Redmine::Plugin.find(:red_counter).directory + '/tests/fixtures/', [:rc_types])

  def setup
    TestUtils.set_workday_default
    TestUtils.enable_module_on_project 1
    @request.session[:user_id] = 1
  end

  #
  # params
  #
  def test_param_issue
    cf_time_in_new = TestUtils.create_custom_filed 'IssueCustomField', 'Time_In_New', 'float', 1
    rcConfig_Time_In_New = RcConfig.create(description: "New Counter", status_id: 1, rc_type_id: 1, custom_field_id: cf_time_in_new.id)

    Issue.delete_all 

    i = TestUtils.create_issue(Time.new(2020, 11, 2, 11, 30), "RedCounter:  new", 1)
    i2 = TestUtils.create_issue(Time.new(2020, 11, 2, 11, 30), "RedCounter:  new 2", 1)

    now = Time.new(2020, 11, 2, 24, 00)
    res = Red_Counter::Helper.eval_time_spent_full nil, nil, now, true, true
    assert_equal 2, res.keys.count
    assert res.key?(i.id)
    assert res.key?(i2.id)

    now = Time.new(2020, 11, 2, 24, 00)
    res = Red_Counter::Helper.eval_time_spent_full [i], nil, now, true, true
    assert_equal 1, res.keys.count
    assert res.key?(i.id)
  end

  def test_param_now
    cf_time_in_new = TestUtils.create_custom_filed 'IssueCustomField', 'Time_In_New', 'float', 1
    rcConfig_Time_In_New = RcConfig.create(description: "New Counter", status_id: 1, rc_type_id: 1, custom_field_id: cf_time_in_new.id)

    i = TestUtils.create_issue(Time.new(2020, 11, 2, 11, 30), "RedCounter:  new", 1)

    now = Time.new(2020, 11, 2, 24, 00)
    res = Red_Counter::Helper.eval_time_spent_full [i], nil, now    , true, true
    assert_equal 5*60*60, res[i.id][cf_time_in_new.id]

    now = Time.new(2020, 11, 3, 10, 00)
    res = Red_Counter::Helper.eval_time_spent_full [i], nil, now, true, true
    assert_equal 5*60*60 + 1.5*60*60, res[i.id][cf_time_in_new.id]
  end

  def test_new_cfg_issue_all_issue
    cf_time_in_new = TestUtils.create_custom_filed 'IssueCustomField', 'Time_In_New', 'float', 1
    rcConfig_Time_In_New = RcConfig.create(description: "New Counter", status_id: 1, rc_type_id: 1, custom_field_id: cf_time_in_new.id)

    Issue.delete_all 

    i = TestUtils.create_issue(Time.new(2020, 11, 2, 11, 30), "RedCounter:  new", 1)
    i2 = TestUtils.create_issue(Time.new(2020, 10, 30, 11, 30), "RedCounter:  new 2", 1)

    now = Time.new(2020, 11, 3, 11, 30)
    res = Red_Counter::Helper.eval_time_spent_full nil, nil, now, true, true

    assert_equal 8*60*60, res[i.id][cf_time_in_new.id]
    assert_equal 5*60*60 + 8*60*60 + 3*60*60, res[i2.id][cf_time_in_new.id]
  end

  def test_param_proj_enabled
    cf_time_in_new = TestUtils.create_custom_filed 'IssueCustomField', 'Time_In_New', 'float', 1
    rcConfig_Time_In_New = RcConfig.create(description: "New Counter", status_id: 1, rc_type_id: 1, custom_field_id: cf_time_in_new.id)

    Issue.delete_all 

    i1 = TestUtils.create_issue(Time.new(2020, 11, 2, 11, 30), "RedCounter:  new", 1, project_id = 1)
    i2 = TestUtils.create_issue(Time.new(2020, 11, 2, 10, 30), "RedCounter:  new 2", 1, project_id = 2)

    now = Time.new(2020, 11, 3, 11, 30)
    res = Red_Counter::Helper.eval_time_spent_full nil, nil, now, true, true

    assert res.key?(i1.id)
    assert_not res.key?(i2.id)

    TestUtils.enable_module_on_project 2
    res = Red_Counter::Helper.eval_time_spent_full nil, nil, now, true, true

    assert res.key?(i1.id)
    assert res.key?(i2.id)

    TestUtils.disable_module_on_project 2
    res = Red_Counter::Helper.eval_time_spent_full nil, nil, now, true, true

    assert res.key?(i1.id)
    assert_not res.key?(i2.id)
  end

  def test_param_proj
    cf_time_in_new = TestUtils.create_custom_filed 'IssueCustomField', 'Time_In_New', 'float', 1
    rcConfig_Time_In_New = RcConfig.create(description: "New Counter", status_id: 1, rc_type_id: 1, custom_field_id: cf_time_in_new.id)

    Issue.delete_all 
    TestUtils.disable_module_on_project 1
    TestUtils.disable_module_on_project 2
    TestUtils.enable_module_on_project 3   # this is always enabled


    i1 = TestUtils.create_issue(Time.new(2020, 11, 2, 11, 30), "RedCounter:  new", 1, project_id = 1)
    i2 = TestUtils.create_issue(Time.new(2020, 11, 2, 10, 30), "RedCounter:  new 2", 1, project_id = 2)
    i3 = TestUtils.create_issue(Time.new(2020, 11, 2, 9, 30), "RedCounter:  new 3", 1, project_id = 3)

    now = Time.new(2020, 11, 3, 11, 30)
    
    # only prj1
    TestUtils.enable_module_on_project 1
    TestUtils.disable_module_on_project 2

    res = Red_Counter::Helper.eval_time_spent_full nil, [1], now, true, true

    assert res.key?(i1.id)
    assert_equal 8*60*60, res[i1.id][cf_time_in_new.id]

    assert_not res.key?(i2.id)

    assert_not res.key?(i3.id)

    # only prj2
    TestUtils.disable_module_on_project 1
    TestUtils.enable_module_on_project 2
    res = Red_Counter::Helper.eval_time_spent_full nil, [2], now, true, true

    assert_not res.key?(i1.id)
    
    assert res.key?(i2.id)
    assert_equal 9*60*60, res[i2.id][cf_time_in_new.id]
    
    assert_not res.key?(i3.id)

    # prj1 and prj2
    TestUtils.enable_module_on_project 1
    TestUtils.enable_module_on_project 2
    res = Red_Counter::Helper.eval_time_spent_full nil, [1, 2], now, true, true

    assert res.key?(i1.id)
    assert_equal 8*60*60, res[i1.id][cf_time_in_new.id]

    assert res.key?(i2.id)
    assert_equal 9*60*60, res[i2.id][cf_time_in_new.id]

    assert_not res.key?(i3.id)

    # all prj
    res = Red_Counter::Helper.eval_time_spent_full nil, nil, now, true, true

    assert res.key?(i1.id)
    assert_equal 8*60*60, res[i1.id][cf_time_in_new.id]

    assert res.key?(i2.id)
    assert_equal 9*60*60, res[i2.id][cf_time_in_new.id]

    assert res.key?(i3.id)
    assert_equal 10*60*60, res[i3.id][cf_time_in_new.id]

  end

end
