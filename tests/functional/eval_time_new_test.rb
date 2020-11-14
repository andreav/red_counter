require File.expand_path('../../test_helper', __FILE__)
require_relative '../test_utils'

class EvalTimeNewTest < ActionController::TestCase
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
    cf_occurences_new = TestUtils.create_custom_filed 'IssueCustomField', 'New occurrences', 'float', 1
    rcConfig_Occurences_New = RcConfig.create(description: "New - Occurrences", status_id: 1, rc_type_id: 1, custom_field_id: cf_occurences_new.id)
  end

  #
  # cfg: new
  #
  def test_new_cfg_issue_new
    cf_time_in_new = TestUtils.create_custom_filed 'IssueCustomField', 'Time_In_New', 'float', 1
    rcConfig_Time_In_New = RcConfig.create(description: "New Counter", status_id: 1, rc_type_id: 1, custom_field_id: cf_time_in_new.id)

    i = TestUtils.create_issue(Time.new(2020, 11, 2, 11, 30), "RedCounter", 1)

    now = Time.new(2020, 11, 2, 24, 00)
    res = Red_Counter::Helper.eval_time_spent_full [i], nil, now, true, true

    assert res.key?(i.id)
    assert res[i.id].key?(cf_time_in_new.id)
    assert_equal 5*60*60, res[i.id][cf_time_in_new.id]
  end

  def test_new_cfg_issue_new_assigned
    cf_time_in_new = TestUtils.create_custom_filed 'IssueCustomField', 'Time_In_New', 'float', 1
    rcConfig_Time_In_New = RcConfig.create(description: "New Counter", status_id: 1, rc_type_id: 1, custom_field_id: cf_time_in_new.id)

    i = TestUtils.create_issue(Time.new(2020, 11, 2, 11, 30), "RedCounter", 1)
    TestUtils.move_issue_to_assigned i, Time.new(2020, 11, 2, 14, 30)

    now = Time.new(2020, 11, 2, 24, 00)
    res = Red_Counter::Helper.eval_time_spent_full [i], nil, now, true, true

    assert_equal 2*60*60, res[i.id][cf_time_in_new.id]
  end

  def test_new_cfg_issue_new_assigned_new
    cf_time_in_new = TestUtils.create_custom_filed 'IssueCustomField', 'Time_In_New', 'float', 1
    rcConfig_Time_In_New = RcConfig.create(description: "New Counter", status_id: 1, rc_type_id: 1, custom_field_id: cf_time_in_new.id)

    i = TestUtils.create_issue(Time.new(2020, 11, 2, 11, 30), "RedCounter", 1)
    TestUtils.move_issue_to_assigned i, Time.new(2020, 11, 2, 14, 30)
    TestUtils.move_issue_to_new i, Time.new(2020, 11, 3, 10, 30)

    now = Time.new(2020, 11, 4, 24, 00)
    res = Red_Counter::Helper.eval_time_spent_full [i], nil, now, true, true

    assert_equal 2*60*60 + 6*60*60 + 8*60*60, res[i.id][cf_time_in_new.id]
  end

  def test_new_cfg_issue_new_assigned_new_resolved
    cf_time_in_new = TestUtils.create_custom_filed 'IssueCustomField', 'Time_In_New', 'float', 1
    rcConfig_Time_In_New = RcConfig.create(description: "New Counter", status_id: 1, rc_type_id: 1, custom_field_id: cf_time_in_new.id)

    i = TestUtils.create_issue(Time.new(2020, 11, 2, 11, 30), "RedCounter", 1)
    TestUtils.move_issue_to_assigned i, Time.new(2020, 11, 2, 14, 30)
    TestUtils.move_issue_to_new i, Time.new(2020, 11, 3, 10, 30)
    TestUtils.move_issue_to_resolved i, Time.new(2020, 11, 3, 18, 30)

    now = Time.new(2020, 11, 4, 24, 00)
    res = Red_Counter::Helper.eval_time_spent_full [i], nil, now, true, true

    assert_equal 2*60*60 + 6*60*60, res[i.id][cf_time_in_new.id]
  end

end
