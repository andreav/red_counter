require File.expand_path('../../test_helper', __FILE__)
require_relative '../test_utils'

class UpsertCounters < ActionController::TestCase
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
    @rc_cfg = Red_Counter::Config.new
  end

  def test_upsert_one_cf
    cf_time_in_assigned = TestUtils.create_custom_filed 'IssueCustomField', 'Time_In_Assigned', 'float', 1
    rcConfig_Time_In_Assigned = RcConfig.create(description: "Assigned Counter", status_id: 2, rc_type_id: 1, custom_field_id: cf_time_in_assigned.id)
    
    i1 = TestUtils.create_issue(Time.new(2020, 11, 2, 11, 30), "RedCounter 1", 1)
    i2 = TestUtils.create_issue(Time.new(2020, 11, 2, 12, 30), "RedCounter 2", 1)

    res = {}
    res[i1.id] = {cf_time_in_assigned.id => 10}
    res[i2.id] = {cf_time_in_assigned.id => 11}

    res = Red_Counter::Helper.upsert_counters res

    i1.reload
    i2.reload

    assert_equal 10, i1.custom_field_value(cf_time_in_assigned.id).to_i
    assert_equal 11, i2.custom_field_value(cf_time_in_assigned.id).to_i
  end

  def test_upsert_two_cf_separed
    cf_time_in_new = TestUtils.create_custom_filed 'IssueCustomField', 'Time_In_New', 'float', 1
    cf_time_in_assigned = TestUtils.create_custom_filed 'IssueCustomField', 'Time_In_Assigned', 'float', 1

    rcConfig_Time_In_New = RcConfig.create(description: "New Counter", status_id: 1, rc_type_id: 1, custom_field_id: cf_time_in_new.id)
    rcConfig_Time_In_Assigned = RcConfig.create(description: "Assigned Counter", status_id: 2, rc_type_id: 1, custom_field_id: cf_time_in_assigned.id)

    i1 = TestUtils.create_issue(Time.new(2020, 11, 2, 11, 30), "RedCounter 1", 1)
    i2 = TestUtils.create_issue(Time.new(2020, 11, 2, 12, 30), "RedCounter 2", 1)

    res = {}
    res[i1.id] = {
      cf_time_in_new.id => 5,
      cf_time_in_assigned.id => 10
    }
    res[i2.id] = {
      cf_time_in_new.id => 6,
      cf_time_in_assigned.id => 11
    }

    res = Red_Counter::Helper.upsert_counters res

    i1.reload
    i2.reload

    assert_equal 5, i1.custom_field_value(cf_time_in_new.id).to_i
    assert_equal 6, i2.custom_field_value(cf_time_in_new.id).to_i
    assert_equal 10, i1.custom_field_value(cf_time_in_assigned.id).to_i
    assert_equal 11, i2.custom_field_value(cf_time_in_assigned.id).to_i
  end

  def test_upsert_one_cf_with_issues_already_created
    i1 = TestUtils.create_issue(Time.new(2020, 11, 2, 11, 30), "RedCounter 1", 1)

    cf_time_in_assigned = TestUtils.create_custom_filed 'IssueCustomField', 'Time_In_Assigned', 'float', 1
    rcConfig_Time_In_Assigned = RcConfig.create(description: "Assigned Counter", status_id: 2, rc_type_id: 1, custom_field_id: cf_time_in_assigned.id)
    
    i2 = TestUtils.create_issue(Time.new(2020, 11, 2, 12, 30), "RedCounter 2", 1)

    res = {}
    res[i1.id] = {cf_time_in_assigned.id => 10}
    res[i2.id] = {cf_time_in_assigned.id => 11}

    res = Red_Counter::Helper.upsert_counters res

    i1.reload
    i2.reload

    assert_equal 10, i1.custom_field_value(cf_time_in_assigned.id).to_i
    assert_equal 11, i2.custom_field_value(cf_time_in_assigned.id).to_i
  end


end
