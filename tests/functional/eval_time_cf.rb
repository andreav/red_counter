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
  def test_cf_float_result_format
    cf_time_in_new_sec = TestUtils.create_custom_filed 'IssueCustomField', 'Time_In_New_Sec', 'float', 1
    cf_time_in_new_min = TestUtils.create_custom_filed 'IssueCustomField', 'Time_In_New_Min', 'float', 1
    cf_time_in_new_hou = TestUtils.create_custom_filed 'IssueCustomField', 'Time_In_New_Hou', 'float', 1
    rcConfig_Time_In_New_Sec = RcConfig.create(description: "New Counter", status_id: 1, rc_type_id: 1, custom_field_id: cf_time_in_new_sec.id, result_format: 'seconds')
    rcConfig_Time_In_New_Min = RcConfig.create(description: "New Counter", status_id: 1, rc_type_id: 1, custom_field_id: cf_time_in_new_min.id, result_format: 'minutes')
    rcConfig_Time_In_New_Hou = RcConfig.create(description: "New Counter", status_id: 1, rc_type_id: 1, custom_field_id: cf_time_in_new_hou.id, result_format: 'hours')

    Issue.delete_all 

    i1 = TestUtils.create_issue(Time.new(2020, 11, 2, 12, 00), "RedCounter:  new", 1)

    now = Time.new(2020, 11, 2, 24, 00)
    res = Red_Counter::Helper.eval_time_spent_full_by_journals nil, nil, now
    
    assert_equal 4.5*60*60, res[i1.id][cf_time_in_new_sec.id]
    assert_equal 4.5*60   , res[i1.id][cf_time_in_new_min.id]
    assert_equal 4.5      , res[i1.id][cf_time_in_new_hou.id]
  end

  def test_cf_int_result_format
    cf_time_in_new_sec = TestUtils.create_custom_filed 'IssueCustomField', 'Time_In_New_Sec', 'int', 1
    cf_time_in_new_min = TestUtils.create_custom_filed 'IssueCustomField', 'Time_In_New_Min', 'int', 1
    cf_time_in_new_hou = TestUtils.create_custom_filed 'IssueCustomField', 'Time_In_New_Hou', 'int', 1
    rcConfig_Time_In_New_Sec = RcConfig.create(description: "New Counter", status_id: 1, rc_type_id: 1, custom_field_id: cf_time_in_new_sec.id, result_format: 'seconds')
    rcConfig_Time_In_New_Min = RcConfig.create(description: "New Counter", status_id: 1, rc_type_id: 1, custom_field_id: cf_time_in_new_min.id, result_format: 'minutes')
    rcConfig_Time_In_New_Hou = RcConfig.create(description: "New Counter", status_id: 1, rc_type_id: 1, custom_field_id: cf_time_in_new_hou.id, result_format: 'hours')

    Issue.delete_all 

    i1 = TestUtils.create_issue(Time.new(2020, 11, 2, 12, 00), "RedCounter:  new", 1)

    now = Time.new(2020, 11, 2, 24, 00)
    res = Red_Counter::Helper.eval_time_spent_full_by_journals nil, nil, now
    
    assert_equal 4.5*60*60, res[i1.id][cf_time_in_new_sec.id]
    assert_equal 4.5*60   , res[i1.id][cf_time_in_new_min.id]
    assert_equal 4      , res[i1.id][cf_time_in_new_hou.id]
  end

end
