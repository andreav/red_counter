require File.expand_path('../../test_helper', __FILE__)
require_relative '../test_utils'

class RakeTaskTest < ActionController::TestCase
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
  # cfg: new + assigned in same counter
  #
  def test_newass_cfg_issue_new
    cf_time_in_new_and_assigned = TestUtils.create_custom_filed 'IssueCustomField', 'Time_In_New_And_Assigned', 'float', 1
    rcConfig_Time_In_Assigned = RcConfig.create(description: "New and Assigned Counter", status_id: 1, rc_type_id: 1, custom_field_id: cf_time_in_new_and_assigned.id)
    rcConfig_Time_In_Assigned = RcConfig.create(description: "New and Assigned Counter", status_id: 2, rc_type_id: 1, custom_field_id: cf_time_in_new_and_assigned.id)

    i = TestUtils.create_issue(Time.new(2020, 11, 2, 7, 30), "RedCounter", 1)

    now = Time.new(2020, 11, 2, 12, 00)
    res = Red_Counter::Helper.eval_time_spent_full_by_journals [i], nil, now

    assert_equal 3.5*60*60, res[i.id][cf_time_in_new_and_assigned.id]
  end

  def test_newass_cfg_issue_new_assigned
    cf_time_in_new_and_assigned = TestUtils.create_custom_filed 'IssueCustomField', 'Time_In_New_And_Assigned', 'float', 1
    rcConfig_Time_In_Assigned = RcConfig.create(description: "New and Assigned Counter", status_id: 1, rc_type_id: 1, custom_field_id: cf_time_in_new_and_assigned.id)
    rcConfig_Time_In_Assigned = RcConfig.create(description: "New and Assigned Counter", status_id: 2, rc_type_id: 1, custom_field_id: cf_time_in_new_and_assigned.id)

    i = TestUtils.create_issue(Time.new(2020, 11, 2, 7, 30), "RedCounter", 1)
    TestUtils.move_issue_to_assigned i, Time.new(2020, 11, 2, 9, 00)

    now = Time.new(2020, 11, 2, 13, 00)
    res = Red_Counter::Helper.eval_time_spent_full_by_journals [i], nil, now

    assert_equal 4*60*60, res[i.id][cf_time_in_new_and_assigned.id]
  end

  def test_newass_cfg_issue_new_assigned_new
    cf_time_in_new_and_assigned = TestUtils.create_custom_filed 'IssueCustomField', 'Time_In_New_And_Assigned', 'float', 1
    rcConfig_Time_In_Assigned = RcConfig.create(description: "New and Assigned Counter", status_id: 1, rc_type_id: 1, custom_field_id: cf_time_in_new_and_assigned.id)
    rcConfig_Time_In_Assigned = RcConfig.create(description: "New and Assigned Counter", status_id: 2, rc_type_id: 1, custom_field_id: cf_time_in_new_and_assigned.id)

    i = TestUtils.create_issue(Time.new(2020, 11, 2, 7, 30), "RedCounter", 1)
    TestUtils.move_issue_to_assigned i, Time.new(2020, 11, 2, 9, 00)
    TestUtils.move_issue_to_new i, Time.new(2020, 11, 2, 10, 00)

    now = Time.new(2020, 11, 2, 19, 00)
    res = Red_Counter::Helper.eval_time_spent_full_by_journals [i], nil, now

    assert_equal 8*60*60, res[i.id][cf_time_in_new_and_assigned.id]
  end

  def test_newass_cfg_issue_new_assigned_new_resolved
    cf_time_in_new_and_assigned = TestUtils.create_custom_filed 'IssueCustomField', 'Time_In_New_And_Assigned', 'float', 1
    rcConfig_Time_In_Assigned = RcConfig.create(description: "New and Assigned Counter", status_id: 1, rc_type_id: 1, custom_field_id: cf_time_in_new_and_assigned.id)
    rcConfig_Time_In_Assigned = RcConfig.create(description: "New and Assigned Counter", status_id: 2, rc_type_id: 1, custom_field_id: cf_time_in_new_and_assigned.id)

    i = TestUtils.create_issue(Time.new(2020, 11, 2, 7, 30), "RedCounter", 1)
    TestUtils.move_issue_to_assigned i, Time.new(2020, 11, 2, 9, 00)
    TestUtils.move_issue_to_new i, Time.new(2020, 11, 2, 10, 00)
    TestUtils.move_issue_to_resolved i, Time.new(2020, 11, 2, 11, 00)

    now = Time.new(2020, 11, 2, 19, 00)
    res = Red_Counter::Helper.eval_time_spent_full_by_journals [i], nil, now

    assert_equal 2.5*60*60, res[i.id][cf_time_in_new_and_assigned.id]
  end

  def test_newass_cfg_issue_new_resolved_assigned_resolved
    cf_time_in_new_and_assigned = TestUtils.create_custom_filed 'IssueCustomField', 'Time_In_New_And_Assigned', 'float', 1
    rcConfig_Time_In_Assigned = RcConfig.create(description: "New and Assigned Counter", status_id: 1, rc_type_id: 1, custom_field_id: cf_time_in_new_and_assigned.id)
    rcConfig_Time_In_Assigned = RcConfig.create(description: "New and Assigned Counter", status_id: 2, rc_type_id: 1, custom_field_id: cf_time_in_new_and_assigned.id)

    i = TestUtils.create_issue(Time.new(2020, 11, 2, 7, 30), "RedCounter", 1)
    TestUtils.move_issue_to_resolved i, Time.new(2020, 11, 2, 9, 00)
    TestUtils.move_issue_to_assigned i, Time.new(2020, 11, 2, 10, 00)
    TestUtils.move_issue_to_resolved i, Time.new(2020, 11, 2, 11, 00)

    now = Time.new(2020, 11, 2, 19, 00)
    res = Red_Counter::Helper.eval_time_spent_full_by_journals [i], nil, now

    assert_equal 1.5*60*60, res[i.id][cf_time_in_new_and_assigned.id]
  end

end
