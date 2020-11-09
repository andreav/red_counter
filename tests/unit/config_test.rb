# -*- encoding : utf-8 -*-
require File.expand_path('../../test_helper', __FILE__)
require_relative '../test_utils'

class ConfigTest < ActiveSupport::TestCase
  def setup
    TestUtils.set_workday_default
  end

  test "Default 8:30-12:30 13:30-17:30" do
    c = Red_Counter::Config.new
    assert_equal c.rc_start_wordday_time_1, Tod::TimeOfDay.new(8,30)
    assert_equal c.rc_end_wordday_time_1, Tod::TimeOfDay.new(12,30)
    assert_equal c.rc_start_wordday_time_2, Tod::TimeOfDay.new(13,30)
    assert_equal c.rc_end_wordday_time_2, Tod::TimeOfDay.new(17,30)

    assert_equal c.wordday_duration_seconds, 28800
    
    assert_equal c.workday_start_time, Tod::TimeOfDay.new(8,30)
    assert_equal c.workday_end_time, Tod::TimeOfDay.new(17,30)
    assert_equal c.workday_period_1, Tod::Shift.new(Tod::TimeOfDay.new(8,30), Tod::TimeOfDay.new(12,30))
    assert_equal c.workday_period_2, Tod::Shift.new(Tod::TimeOfDay.new(13,30), Tod::TimeOfDay.new(17,30))

  end

  test "Override default + null minutes => 0 minutes" do

    TestUtils.set_workday_period_1 7, '', 11, ''
    TestUtils.set_workday_period_2 12, '', 16, ''

    c = Red_Counter::Config.new
    assert_equal c.rc_start_wordday_time_1, Tod::TimeOfDay.new(7,00)
    assert_equal c.rc_end_wordday_time_1, Tod::TimeOfDay.new(11,00)
    assert_equal c.rc_start_wordday_time_2, Tod::TimeOfDay.new(12,00)
    assert_equal c.rc_end_wordday_time_2, Tod::TimeOfDay.new(16,00)
  end

  test "First Period Null" do

    TestUtils.set_workday_period_1 '', '', '', ''
    TestUtils.set_workday_period_2 17, 10, 18, 20

    c = Red_Counter::Config.new
    assert_nil c.rc_start_wordday_time_1
    assert_nil c.rc_end_wordday_time_1
    assert_equal c.rc_start_wordday_time_2, Tod::TimeOfDay.new(17,10)
    assert_equal c.rc_end_wordday_time_2, Tod::TimeOfDay.new(18,20)

    assert_equal c.wordday_duration_seconds, 4200
    
    assert_equal c.workday_start_time, Tod::TimeOfDay.new(17,10)
    assert_equal c.workday_end_time, Tod::TimeOfDay.new(18,20)
    assert_equal c.workday_period_1, Tod::Shift.new(0, 0)
    assert_equal c.workday_period_2, Tod::Shift.new(Tod::TimeOfDay.new(17,10), Tod::TimeOfDay.new(18,20))
  end

  test "Second Period Null" do

    TestUtils.set_workday_period_1 10, 10, 11, 10
    TestUtils.set_workday_period_2 '', '', '', ''

    c = Red_Counter::Config.new
    assert_equal c.rc_start_wordday_time_1, Tod::TimeOfDay.new(10,10)
    assert_equal c.rc_end_wordday_time_1, Tod::TimeOfDay.new(11,10)
    assert_nil c.rc_start_wordday_time_2
    assert_nil c.rc_end_wordday_time_2

    assert_equal c.wordday_duration_seconds, 3600
    
    assert_equal c.workday_start_time, Tod::TimeOfDay.new(10,10)
    assert_equal c.workday_end_time, Tod::TimeOfDay.new(11,10)
    assert_equal c.workday_period_1, Tod::Shift.new(Tod::TimeOfDay.new(10,10), Tod::TimeOfDay.new(11, 10))
    assert_equal c.workday_period_2, Tod::Shift.new(0, 0)
  end

end
