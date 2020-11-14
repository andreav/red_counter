require File.expand_path('../../test_helper', __FILE__)
require_relative '../test_utils'

class EvalTimeAssignedTest < ActionController::TestCase
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
  # cfg: assigned
  #
  def test_ass_cfg_issue_new_assigned
    cf_time_in_assigned = TestUtils.create_custom_filed 'IssueCustomField', 'Time_In_Assigned', 'float', 1
    rcConfig_Time_In_Assigned = RcConfig.create(description: "Assigned Counter", status_id: 2, rc_type_id: 1, custom_field_id: cf_time_in_assigned.id)

    i = TestUtils.create_issue(Time.new(2020, 11, 2, 11, 30), "RedCounter", 1)
    TestUtils.move_issue_to_assigned i, Time.new(2020, 11, 2, 14, 30)

    now = Time.new(2020, 11, 3, 9, 30)
    res = Red_Counter::Helper.eval_time_spent_full [i], nil, now, true, true

    assert_equal 3*60*60 + 1*60*60, res[i.id][cf_time_in_assigned.id]
  end

  def test_ass_cfg_issue_new_assigned_resolved
    cf_time_in_assigned = TestUtils.create_custom_filed 'IssueCustomField', 'Time_In_Assigned', 'float', 1
    rcConfig_Time_In_Assigned = RcConfig.create(description: "Assigned Counter", status_id: 2, rc_type_id: 1, custom_field_id: cf_time_in_assigned.id)

    i = TestUtils.create_issue(Time.new(2020, 11, 2, 11, 30), "RedCounter", 1)
    TestUtils.move_issue_to_assigned i, Time.new(2020, 11, 2, 14, 30)
    TestUtils.move_issue_to_resolved i, Time.new(2020, 11, 2, 15, 00)

    now = Time.new(2020, 11, 3, 9, 30)
    res = Red_Counter::Helper.eval_time_spent_full [i], nil, now, true, true

    assert_equal 0.5*60*60, res[i.id][cf_time_in_assigned.id]
  end

  def test_ass_cfg_issue_new_assigned_new_assigned
    cf_time_in_assigned = TestUtils.create_custom_filed 'IssueCustomField', 'Time_In_Assigned', 'float', 1
    rcConfig_Time_In_Assigned = RcConfig.create(description: "Assigned Counter", status_id: 2, rc_type_id: 1, custom_field_id: cf_time_in_assigned.id)

    i = TestUtils.create_issue(Time.new(2020, 11, 2, 8, 30), "RedCounter", 1)
    TestUtils.move_issue_to_assigned i, Time.new(2020, 11, 2, 9, 00)
    TestUtils.move_issue_to_new i, Time.new(2020, 11, 2, 9, 30)
    TestUtils.move_issue_to_assigned i, Time.new(2020, 11, 2, 10, 00)

    now = Time.new(2020, 11, 2, 11, 00)
    res = Red_Counter::Helper.eval_time_spent_full [i], nil, now, true, true

    assert_equal 0.5*60*60 + 1*60*60, res[i.id][cf_time_in_assigned.id]
  end

  def test_ass_cfg_issue_new_assigned_new_assigned_resolved
    cf_time_in_assigned = TestUtils.create_custom_filed 'IssueCustomField', 'Time_In_Assigned', 'float', 1
    rcConfig_Time_In_Assigned = RcConfig.create(description: "Assigned Counter", status_id: 2, rc_type_id: 1, custom_field_id: cf_time_in_assigned.id)

    i = TestUtils.create_issue(Time.new(2020, 11, 2, 8, 30), "RedCounter", 1)
    TestUtils.move_issue_to_assigned i, Time.new(2020, 11, 2, 9, 00)
    TestUtils.move_issue_to_new i, Time.new(2020, 11, 2, 9, 30)
    TestUtils.move_issue_to_assigned i, Time.new(2020, 11, 2, 10, 00)
    TestUtils.move_issue_to_resolved i, Time.new(2020, 11, 2, 11, 00)

    now = Time.new(2020, 11, 2, 12, 00)
    res = Red_Counter::Helper.eval_time_spent_full [i], nil, now, true, true

    assert_equal 0.5*60*60 + 1*60*60, res[i.id][cf_time_in_assigned.id]
  end

end
