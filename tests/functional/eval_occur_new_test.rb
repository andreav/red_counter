require File.expand_path('../../test_helper', __FILE__)
require_relative '../test_utils'

class EvalOccurNewTest < ActionController::TestCase
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
    @cf_time_in_new = TestUtils.create_custom_filed 'IssueCustomField', 'Time_In_New', 'float', 1
    @rcConfig_Time_In_New = RcConfig.create(description: "New Counter", status_id: 1, rc_type_id: Red_Counter::Config::RCTYPE_ELAPSED, custom_field_id: @cf_time_in_new.id)
    @cf_occurences_new = TestUtils.create_custom_filed 'IssueCustomField', 'New occurrences', 'int', 1
    @rcConfig_Occurences_New = RcConfig.create(description: "New - Occurrences", status_id: 1, rc_type_id: Red_Counter::Config::RCTYPE_OCCURRENCES, custom_field_id: @cf_occurences_new.id)
  end

  #
  # cfg: new
  #
  def test_new_cfg_issue_new
    i = TestUtils.create_issue(Time.new(2020, 11, 2, 11, 30), "RedCounter", 1)

    now = Time.new(2020, 11, 2, 24, 00)
    res = Red_Counter::Helper.eval_time_spent_full_by_journals [i], nil, now

    assert res.key?(i.id)
    assert res[i.id].key?(@cf_occurences_new.id)
    assert_equal 1, res[i.id][@cf_occurences_new.id]
  end

  def test_new_cfg_issue_new_assigned
    i = TestUtils.create_issue(Time.new(2020, 11, 2, 11, 30), "RedCounter", 1)
    TestUtils.move_issue_to_assigned i, Time.new(2020, 11, 2, 14, 30)

    now = Time.new(2020, 11, 2, 24, 00)
    res = Red_Counter::Helper.eval_time_spent_full_by_journals [i], nil, now

    assert_equal 1, res[i.id][@cf_occurences_new.id]
  end

  def test_new_cfg_issue_new_assigned_new
    i = TestUtils.create_issue(Time.new(2020, 11, 2, 11, 30), "RedCounter", 1)
    TestUtils.move_issue_to_assigned i, Time.new(2020, 11, 2, 14, 30)
    TestUtils.move_issue_to_new i, Time.new(2020, 11, 3, 10, 30)

    now = Time.new(2020, 11, 4, 24, 00)
    res = Red_Counter::Helper.eval_time_spent_full_by_journals [i], nil, now

    assert_equal 2, res[i.id][@cf_occurences_new.id]
  end

  def test_new_cfg_issue_new_assigned_new_resolved
    i = TestUtils.create_issue(Time.new(2020, 11, 2, 11, 30), "RedCounter", 1)
    TestUtils.move_issue_to_assigned i, Time.new(2020, 11, 2, 14, 30)
    TestUtils.move_issue_to_new i, Time.new(2020, 11, 3, 10, 30)
    TestUtils.move_issue_to_resolved i, Time.new(2020, 11, 3, 18, 30)

    now = Time.new(2020, 11, 4, 24, 00)
    res = Red_Counter::Helper.eval_time_spent_full_by_journals [i], nil, now

    assert_equal 2, res[i.id][@cf_occurences_new.id]
  end

end
