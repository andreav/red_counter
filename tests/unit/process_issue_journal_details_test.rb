# -*- encoding : utf-8 -*-
require File.expand_path('../../test_helper', __FILE__)
require_relative '../test_utils'

class ProcessIssueJournalDetailsTest < ActiveSupport::TestCase

  ST_DEF = -1
  ST_NEW = 1
  ST_ASS = 2
  ST_RES = 3

  def setup
    TestUtils.set_workday_default
    
    @cf = CustomField.find_by type: 'IssueCustomField', name: 'Time_In_Assigned_Float', field_format: 'float'
    if @cf == nil
      @cf = CustomField.create(type: 'IssueCustomField', name: 'Time_In_Assigned_Float', field_format: 'float')
    end

    @journ_det_list = []
    @res = {}

    @rc_config_ass = RcConfig.new(status_id: ST_ASS, rc_type_id: 1, custom_field_id: @cf.id)
    @rc_config_new = RcConfig.new(status_id: ST_NEW, rc_type_id: 1, custom_field_id: @cf.id)

  end

  test "Assigned counter - New -> Assigned -> Resolved" do
    @journ_det_list << TestUtils.fake_journal_det(ST_DEF, ST_NEW, Time.new(2020, 11, 2, 8, 30))
    @journ_det_list << TestUtils.fake_journal_det(ST_NEW, ST_ASS, Time.new(2020, 11, 2, 9, 30))
    @journ_det_list << TestUtils.fake_journal_det(ST_ASS, ST_RES, Time.new(2020, 11, 2, 10, 30))  # <--
    
    Red_Counter::Helper.process_issue_journal_details(@res, @journ_det_list, @rc_config_ass, Red_Counter::Config.new)

    assert @res.key?(-1)
    assert @res[-1].key?(@cf.id)
    assert_equal  1*60*60, @res[-1][@cf.id]
  end

  test "Assigned counter - New -> Assigned -> Resolved -> Assigned -> Resolved" do
    @journ_det_list << TestUtils.fake_journal_det(ST_DEF, ST_NEW, Time.new(2020, 11, 2, 8, 30))
    @journ_det_list << TestUtils.fake_journal_det(ST_NEW, ST_ASS, Time.new(2020, 11, 2, 9, 30))
    @journ_det_list << TestUtils.fake_journal_det(ST_ASS, ST_RES, Time.new(2020, 11, 2, 10, 30))  # <--
    @journ_det_list << TestUtils.fake_journal_det(ST_RES, ST_ASS, Time.new(2020, 11, 2, 11, 00))
    @journ_det_list << TestUtils.fake_journal_det(ST_ASS, ST_RES, Time.new(2020, 11, 2, 11, 10))  # <--
    
    Red_Counter::Helper.process_issue_journal_details(@res, @journ_det_list, @rc_config_ass, Red_Counter::Config.new)

    assert @res.key?(-1)
    assert @res[-1].key?(@cf.id)
    assert_equal  1*60*60 + 10*60, @res[-1][@cf.id]
  end

  test "Assigned counter - New -> Assigned -> Assigned -> Resolved" do
    @journ_det_list << TestUtils.fake_journal_det(ST_DEF, ST_NEW, Time.new(2020, 11, 2, 8, 30))
    @journ_det_list << TestUtils.fake_journal_det(ST_NEW, ST_ASS, Time.new(2020, 11, 2, 9, 30))
    @journ_det_list << TestUtils.fake_journal_det(ST_ASS, ST_ASS, Time.new(2020, 11, 2, 10, 00))  # <--
    @journ_det_list << TestUtils.fake_journal_det(ST_ASS, ST_RES, Time.new(2020, 11, 2, 11, 10))  # <--
    
    Red_Counter::Helper.process_issue_journal_details(@res, @journ_det_list, @rc_config_ass, Red_Counter::Config.new)

    assert @res.key?(-1)
    assert @res[-1].key?(@cf.id)
    assert_equal  0.5*60*60 + (1*60*60 + 10*60), @res[-1][@cf.id]
  end

  test "Assigned counter - New -> Assigned -> Assigned - last Assigned forces count evaluation" do
    @journ_det_list << TestUtils.fake_journal_det(ST_DEF, ST_NEW, Time.new(2020, 11, 2, 8, 30))
    @journ_det_list << TestUtils.fake_journal_det(ST_NEW, ST_ASS, Time.new(2020, 11, 2, 9, 30))
    @journ_det_list << TestUtils.fake_journal_det(ST_ASS, ST_ASS, Time.new(2020, 11, 2, 10, 00))  # <--
    
    Red_Counter::Helper.process_issue_journal_details(@res, @journ_det_list, @rc_config_ass, Red_Counter::Config.new)

    assert @res.key?(-1)
    assert @res[-1].key?(@cf.id)
    assert_equal  0.5*60*60, @res[-1][@cf.id]
  end

  test "Assigned counter - New -> Assigned -> Resolved -> Reoslved -> Assigned -> Resolved" do
    @journ_det_list << TestUtils.fake_journal_det(ST_DEF, ST_NEW, Time.new(2020, 11, 2, 8, 30))
    @journ_det_list << TestUtils.fake_journal_det(ST_NEW, ST_ASS, Time.new(2020, 11, 2, 9, 30))
    @journ_det_list << TestUtils.fake_journal_det(ST_ASS, ST_RES, Time.new(2020, 11, 2, 10, 00))  # <--
    @journ_det_list << TestUtils.fake_journal_det(ST_RES, ST_RES, Time.new(2020, 11, 2, 11, 10))
    @journ_det_list << TestUtils.fake_journal_det(ST_RES, ST_ASS, Time.new(2020, 11, 2, 11, 20))
    @journ_det_list << TestUtils.fake_journal_det(ST_ASS, ST_RES, Time.new(2020, 11, 2, 12, 00))  # <--
    
    Red_Counter::Helper.process_issue_journal_details(@res, @journ_det_list, @rc_config_ass, Red_Counter::Config.new)

    assert @res.key?(-1)
    assert @res[-1].key?(@cf.id)
    assert_equal  0.5*60*60 + 40*60, @res[-1][@cf.id]
  end

  test "Assigned counter - New -> Assigned -> Resolved - including pause" do
    @journ_det_list << TestUtils.fake_journal_det(ST_DEF, ST_NEW, Time.new(2020, 11, 2, 8, 30))
    @journ_det_list << TestUtils.fake_journal_det(ST_NEW, ST_ASS, Time.new(2020, 11, 2, 9, 30))
    @journ_det_list << TestUtils.fake_journal_det(ST_ASS, ST_RES, Time.new(2020, 11, 2, 13, 30))  # <--
    
    Red_Counter::Helper.process_issue_journal_details(@res, @journ_det_list, @rc_config_ass, Red_Counter::Config.new)

    assert @res.key?(-1)
    assert @res[-1].key?(@cf.id)
    assert_equal 3*60*60, @res[-1][@cf.id] # not counting 12:30 -> 13:30
  end

  test "Assigned counter - New -> Assigned -> Resolved - including pause and more" do
    @journ_det_list << TestUtils.fake_journal_det(ST_DEF, ST_NEW, Time.new(2020, 11, 2, 8, 30))
    @journ_det_list << TestUtils.fake_journal_det(ST_NEW, ST_ASS, Time.new(2020, 11, 2, 9, 30))
    @journ_det_list << TestUtils.fake_journal_det(ST_ASS, ST_RES, Time.new(2020, 11, 2, 15, 30))  # <--
    
    Red_Counter::Helper.process_issue_journal_details(@res, @journ_det_list, @rc_config_ass, Red_Counter::Config.new)

    assert @res.key?(-1)
    assert @res[-1].key?(@cf.id)
    assert_equal 5*60*60, @res[-1][@cf.id] # not counting 12:30 -> 13:30
  end

  test "Assigned counter - New -> Assigned -> Resolved - day after" do
    @journ_det_list << TestUtils.fake_journal_det(ST_DEF, ST_NEW, Time.new(2020, 11, 2, 8, 30))
    @journ_det_list << TestUtils.fake_journal_det(ST_NEW, ST_ASS, Time.new(2020, 11, 2, 9, 30))
    @journ_det_list << TestUtils.fake_journal_det(ST_ASS, ST_RES, Time.new(2020, 11, 3, 9, 30))  # <--
    
    Red_Counter::Helper.process_issue_journal_details(@res, @journ_det_list, @rc_config_ass, Red_Counter::Config.new)

    assert @res.key?(-1)
    assert @res[-1].key?(@cf.id)
    assert_equal  8*60*60, @res[-1][@cf.id]
  end

  test "New counter - New -> Assigned -> Resolved" do
    @journ_det_list << TestUtils.fake_journal_det(ST_DEF, ST_NEW, Time.new(2020, 11, 2, 9, 00))
    @journ_det_list << TestUtils.fake_journal_det(ST_NEW, ST_ASS, Time.new(2020, 11, 2, 9, 30))  # <--
    @journ_det_list << TestUtils.fake_journal_det(ST_ASS, ST_RES, Time.new(2020, 11, 2, 10, 30))
    
    Red_Counter::Helper.process_issue_journal_details(@res, @journ_det_list, @rc_config_new, Red_Counter::Config.new)

    assert @res.key?(-1)
    assert @res[-1].key?(@cf.id)
    assert_equal  0.5*60*60, @res[-1][@cf.id]
  end

  test "New counter - New -> Assigned -> Assinged" do
    @journ_det_list << TestUtils.fake_journal_det(ST_DEF, ST_NEW, Time.new(2020, 11, 2, 9, 10))
    @journ_det_list << TestUtils.fake_journal_det(ST_NEW, ST_ASS, Time.new(2020, 11, 2, 9, 30))  # <--
    @journ_det_list << TestUtils.fake_journal_det(ST_ASS, ST_ASS, Time.new(2020, 11, 2, 10, 30))
    rc_config = RcConfig.new(status_id: ST_ASS, rc_type_id: 1, custom_field_id: @cf.id)
    
    Red_Counter::Helper.process_issue_journal_details(@res, @journ_det_list, @rc_config_new, Red_Counter::Config.new)

    assert @res.key?(-1)
    assert @res[-1].key?(@cf.id)
    assert_equal  20*60, @res[-1][@cf.id]
  end

  test "New counter - New -> Asinged -> New" do
    @journ_det_list << TestUtils.fake_journal_det(ST_DEF, ST_NEW, Time.new(2020, 11, 2, 9, 10))
    @journ_det_list << TestUtils.fake_journal_det(ST_NEW, ST_ASS, Time.new(2020, 11, 2, 9, 30))  # <--
    @journ_det_list << TestUtils.fake_journal_det(ST_ASS, ST_NEW, Time.new(2020, 11, 2, 10, 30))
    rc_config = RcConfig.new(status_id: ST_ASS, rc_type_id: 1, custom_field_id: @cf.id)
    
    Red_Counter::Helper.process_issue_journal_details(@res, @journ_det_list, @rc_config_new, Red_Counter::Config.new)

    assert @res.key?(-1)
    assert @res[-1].key?(@cf.id)
    assert_equal  20*60, @res[-1][@cf.id]
  end

  test "New counter - New -> New -> Asinged" do
    @journ_det_list << TestUtils.fake_journal_det(ST_DEF, ST_NEW, Time.new(2020, 11, 2, 9, 10))
    @journ_det_list << TestUtils.fake_journal_det(ST_NEW, ST_NEW, Time.new(2020, 11, 2, 9, 30))   # <--
    @journ_det_list << TestUtils.fake_journal_det(ST_NEW, ST_ASS, Time.new(2020, 11, 2, 10, 30))  # <--
    rc_config = RcConfig.new(status_id: ST_ASS, rc_type_id: 1, custom_field_id: @cf.id)
    
    Red_Counter::Helper.process_issue_journal_details(@res, @journ_det_list, @rc_config_new, Red_Counter::Config.new)

    assert @res.key?(-1)
    assert @res[-1].key?(@cf.id)
    assert_equal  20*60 + 1*60*60, @res[-1][@cf.id]
  end

  test "New counter - New" do
    @journ_det_list << TestUtils.fake_journal_det(ST_DEF, ST_NEW, Time.new(2020, 11, 2, 9, 10))
    @journ_det_list << TestUtils.fake_journal_det(ST_NEW, ST_NEW, Time.new(2020, 11, 2, 9, 30))   # <--
    rc_config = RcConfig.new(status_id: ST_ASS, rc_type_id: 1, custom_field_id: @cf.id)
    
    Red_Counter::Helper.process_issue_journal_details(@res, @journ_det_list, @rc_config_new, Red_Counter::Config.new)

    assert @res.key?(-1)
    assert @res[-1].key?(@cf.id)
    assert_equal  20*60, @res[-1][@cf.id]
  end

  test "New counter - New - with pause" do
    @journ_det_list << TestUtils.fake_journal_det(ST_DEF, ST_NEW, Time.new(2020, 11, 2, 8, 30))
    @journ_det_list << TestUtils.fake_journal_det(ST_NEW, ST_NEW, Time.new(2020, 11, 2, 20, 00))   # <--
    rc_config = RcConfig.new(status_id: ST_ASS, rc_type_id: 1, custom_field_id: @cf.id)
    
    Red_Counter::Helper.process_issue_journal_details(@res, @journ_det_list, @rc_config_new, Red_Counter::Config.new)

    assert @res.key?(-1)
    assert @res[-1].key?(@cf.id)
    assert_equal  8*60*60, @res[-1][@cf.id]
  end

end
