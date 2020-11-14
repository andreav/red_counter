require File.expand_path('../../test_helper', __FILE__)
require_relative '../test_utils'

class EvalTimeMixedTest < ActionController::TestCase
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
  # cfg: different counters
  #
  def test_time_in_assigned_all_issues
    Issue.delete_all

    cf_time_in_new = TestUtils.create_custom_filed 'IssueCustomField', 'Time_In_New', 'float', 1
    cf_time_in_assigned = TestUtils.create_custom_filed 'IssueCustomField', 'Time_In_Assigned', 'float', 1
    
    rcConfig_Time_In_New = RcConfig.create(description: "New Counter", status_id: 1, rc_type_id: 1, custom_field_id: cf_time_in_new.id)
    rcConfig_Time_In_Assigned = RcConfig.create(description: "Assigned Counter", status_id: 2, rc_type_id: 1, custom_field_id: cf_time_in_assigned.id)

    i1 = TestUtils.create_issue(Time.new(2020, 11, 2, 9, 00), "RedCounter 1: new -> assigned -> resolved", 1)
    TestUtils.move_issue_to_assigned i1, Time.new(2020, 11, 2, 9, 30)
    TestUtils.move_issue_to_resolved i1, Time.new(2020, 11, 2, 11, 30)

    i2 = TestUtils.create_issue(Time.new(2020, 11, 2, 8, 00), "RedCounter 2: new -> assigned -> resolved -> assigned", 1)
    TestUtils.move_issue_to_assigned i2, Time.new(2020, 11, 2, 9, 30)
    TestUtils.move_issue_to_resolved i2, Time.new(2020, 11, 2, 11, 30)
    TestUtils.move_issue_to_assigned i2, Time.new(2020, 11, 2, 12, 00)

    i3 = TestUtils.create_issue(Time.new(2020, 11, 2, 9, 00), "RedCounter 3: new -> assigned", 1)
    TestUtils.move_issue_to_assigned i3, Time.new(2020, 11, 2, 9, 30)

    i4 = TestUtils.create_issue(Time.new(2020, 11, 2, 11, 30), "RedCounter 4:  new", 1)

    now = Time.new(2020, 11, 2, 24, 00)
    res = Red_Counter::Helper.eval_time_spent_full nil, nil, now, true, true

    assert_equal 0.5*60*60, res[i1.id][cf_time_in_new.id]
    assert_equal 2*60*60, res[i1.id][cf_time_in_assigned.id]

    assert_equal 1*60*60, res[i2.id][cf_time_in_new.id]
    assert_equal 2*60*60 + 0.5*60*60 + 4*60*60, res[i2.id][cf_time_in_assigned.id]

    assert_equal 0.5*60*60, res[i3.id][cf_time_in_new.id]
    assert_equal 7*60*60, res[i3.id][cf_time_in_assigned.id]

    assert_equal 5*60*60, res[i4.id][cf_time_in_new.id]
    assert_not res[i4.id].keys.include?(cf_time_in_assigned.id)

  end

  def test_time_in_new_and_assigned_all_issues
    Issue.delete_all

    cf_time_in_new_and_assigned = TestUtils.create_custom_filed 'IssueCustomField', 'Time_In_New_And_Assigned', 'float', 1
    rcConfig_Time_In_Assigned = RcConfig.create(description: "New and Assigned Counter", status_id: 1, rc_type_id: 1, custom_field_id: cf_time_in_new_and_assigned.id)
    rcConfig_Time_In_Assigned = RcConfig.create(description: "New and Assigned Counter", status_id: 2, rc_type_id: 1, custom_field_id: cf_time_in_new_and_assigned.id)

    i1 = TestUtils.create_issue(Time.new(2020, 11, 2, 9, 00), "RedCounter 1: new -> assigned -> resolved", 1)
    TestUtils.move_issue_to_assigned i1, Time.new(2020, 11, 2, 9, 30)
    TestUtils.move_issue_to_resolved i1, Time.new(2020, 11, 2, 11, 30)

    i2 = TestUtils.create_issue(Time.new(2020, 11, 2, 8, 00), "RedCounter 2: new -> assigned -> resolved -> assigned", 1)
    TestUtils.move_issue_to_assigned i2, Time.new(2020, 11, 2, 9, 30)
    TestUtils.move_issue_to_resolved i2, Time.new(2020, 11, 2, 11, 30)
    TestUtils.move_issue_to_assigned i2, Time.new(2020, 11, 2, 12, 00)

    i3 = TestUtils.create_issue(Time.new(2020, 11, 2, 9, 00), "RedCounter 3: new -> assigned", 1)
    TestUtils.move_issue_to_assigned i3, Time.new(2020, 11, 2, 9, 30)

    i4 = TestUtils.create_issue(Time.new(2020, 11, 2, 11, 30), "RedCounter 4:  new", 1)

    now = Time.new(2020, 11, 2, 24, 00)
    res = Red_Counter::Helper.eval_time_spent_full nil, nil, now, true, true

    assert_equal 0.5*60*60 + 2*60*60, res[i1.id][cf_time_in_new_and_assigned.id]

    assert_equal 1*60*60 + (2*60*60 + 0.5*60*60 + 4*60*60), res[i2.id][cf_time_in_new_and_assigned.id]

    assert_equal 0.5*60*60 + 7*60*60, res[i3.id][cf_time_in_new_and_assigned.id]

    assert_equal 5*60*60, res[i4.id][cf_time_in_new_and_assigned.id]

  end

end
