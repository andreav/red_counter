# -*- encoding : utf-8 -*-
require File.expand_path('../../test_helper', __FILE__)
require_relative '../test_utils'

class EvalEffectiveHoursTest < ActiveSupport::TestCase
  def setup
    TestUtils.set_workday_default
  end

  #
  # One day
  #
  test "Same work day - from inside period_1 to inside period_1 returns just the difference" do
    fromTime = Time.new(2020, 11, 2, 9, 0)
    toTime = Time.new(2020, 11, 2, 10, 0)
    assert_equal 1*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "Same work day - from inside period_2 to inside period_2 returns just the difference" do
    fromTime = Time.new(2020, 11, 2, 15, 0)
    toTime = Time.new(2020, 11, 2, 16, 0)
    assert_equal 1*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "Same work day - from inside period_1 to inside period_2 returns the difference but the pause" do
    fromTime = Time.new(2020, 11, 2, 9, 0)
    toTime = Time.new(2020, 11, 2, 16, 0)
    assert_equal 3.5*60*60 + 2.5*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "Same work day - from before period_1 to before period_1: 0" do
    fromTime = Time.new(2020, 11, 2, 5, 0)
    toTime = Time.new(2020, 11, 2, 6, 0)
    assert_equal 0, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "Same work day - from before period_1 to inside period_1: shift from at 8:30" do
    fromTime = Time.new(2020, 11, 2, 5, 0)
    toTime = Time.new(2020, 11, 2, 11, 30)
    assert_equal 3*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "Same work day - from before period_1 to inside pause between: shift from at 8:30, shift to at 12:30" do
    fromTime = Time.new(2020, 11, 2, 5, 0)
    toTime = Time.new(2020, 11, 2, 13, 00)
    assert_equal 4*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "Same work day - from before period_1 to inside period_2: shift from at 8:30 - do not count pause" do
    fromTime = Time.new(2020, 11, 2, 5, 0)
    toTime = Time.new(2020, 11, 2, 14, 30)
    assert_equal 4*60*60 + 1*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "Same work day - from before period_1 to after period_2: shift from at 8:30, shift to at 17:30 - do not count pause" do
    fromTime = Time.new(2020, 11, 2, 5, 0)
    toTime = Time.new(2020, 11, 2, 20, 30)
    assert_equal 4*60*60 + 4*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "Same holyday day - from inside period_1 to inside period_1 returns 0" do
    fromTime = Time.new(2020, 11, 1, 9, 0)
    toTime = Time.new(2020, 11, 1, 10, 0)
    assert_equal 0, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "Same holyday day - from before period_1 to after period_2 returns 0" do
    fromTime = Time.new(2020, 11, 1, 5, 0)
    toTime = Time.new(2020, 11, 1, 20, 0)
    assert_equal 0, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "Same Day - edge case - from at finish period_1 to at beginning period_2 returns 0" do
    fromTime = Time.new(2020, 11, 2, 12, 30)
    toTime = Time.new(2020, 11, 2, 13, 30)
    assert_equal 0, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "Same Day - edge case - from at finish period_1 to at finish period_2" do
    fromTime = Time.new(2020, 11, 2, 12, 30)
    toTime = Time.new(2020, 11, 2, 17, 30)
    assert_equal 4*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  #
  # two days, no holidays
  #
  test "two days - no holidays - from inside period_1 to inside period_1" do
    fromTime = Time.new(2020, 11, 2, 9, 0)
    toTime = Time.new(2020, 11, 3, 10, 0)
    assert_equal 7.5*60*60 + 1.5*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "two days - no holidays - from inside period_2 to inside period_2" do
    fromTime = Time.new(2020, 11, 2, 16, 30)
    toTime = Time.new(2020, 11, 3, 16, 0)
    assert_equal 1*60*60 + 6.5*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "two days - no holidays - from inside period_1 to inside period_2" do
    fromTime = Time.new(2020, 11, 2, 9, 0)
    toTime = Time.new(2020, 11, 3, 15, 0)
    assert_equal 7.5*60*60 + 5.5*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "two days - no holidays - from before period_1 to after period_2" do
    fromTime = Time.new(2020, 11, 2, 5, 0)
    toTime = Time.new(2020, 11, 3, 21, 0)
    assert_equal 8*60*60 + 8*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "two days - no holidays - from after period_2 to before period_1" do
    fromTime = Time.new(2020, 11, 2, 20, 30)
    toTime = Time.new(2020, 11, 3, 5, 0)
    assert_equal 0, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "two days - no holidays - edge case - from at finish period_2 to at beginning period_1" do
    fromTime = Time.new(2020, 11, 2, 17, 30)
    toTime = Time.new(2020, 11, 3, 8, 30)
    assert_equal 0, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "two days - no holidays - edge case - from at finish period_2 to at beginning period_2" do
    fromTime = Time.new(2020, 11, 2, 17, 30)
    toTime = Time.new(2020, 11, 3, 13, 30)
    assert_equal 0*60*60 + 4*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  #
  # two days, with holidays in the middle
  # Choosing with attention fromTime and toTime, we must have same result as "two days no holidays"
  #
  test "two days - with holidays in the middle - from inside period_1 to inside period_1" do
    fromTime = Time.new(2020, 10, 30, 9, 0)
    toTime = Time.new(2020, 11, 2, 10, 0)
    assert_equal 7.5*60*60 + 1.5*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "two days - with holidays in the middle - from inside period_2 to inside period_2" do
    fromTime = Time.new(2020, 10, 30, 16, 30)
    toTime = Time.new(2020, 11, 2, 16, 0)
    assert_equal 1*60*60 + 6.5*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "two days - with holidays in the middle - from inside period_1 to inside period_2" do
    fromTime = Time.new(2020, 10, 30, 9, 0)
    toTime = Time.new(2020, 11, 2, 15, 0)
    assert_equal 7.5*60*60 + 5.5*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "two days - with holidays in the middle - from before period_1 to after period_2" do
    fromTime = Time.new(2020, 10, 30, 5, 0)
    toTime = Time.new(2020, 11, 2, 21, 0)
    assert_equal 8*60*60 + 8*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "two days - with holidays in the middle - from after period_2 to before period_1" do
    fromTime = Time.new(2020, 10, 30, 20, 30)
    toTime = Time.new(2020, 11, 2, 5, 0)
    assert_equal 0, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "two days - with holidays in the middle - edge case - from at finish period_2 to at beginning period_1" do
    fromTime = Time.new(2020, 10, 30, 17, 30)
    toTime = Time.new(2020, 11, 2, 8, 30)
    assert_equal 0, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "two days - with holidays in the middle - edge case - from at finish period_2 to at beginning period_2" do
    fromTime = Time.new(2020, 10, 30, 17, 30)
    toTime = Time.new(2020, 11, 2, 13, 30)
    assert_equal 0*60*60 + 4*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end
  
  #
  # multiple days, no holidays
  # Choosing with attention fromTime and toTime, we must have same result as "two days no holidays" adding 2 working days
  #
  test "multiple days - no holidays - from inside period_1 to inside period_1" do
    fromTime = Time.new(2020, 11, 2, 9, 0)
    toTime = Time.new(2020, 11, 5, 10, 0)
    assert_equal 7.5*60*60 + 1.5*60*60 + 16*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "multiple days - no holidays - from inside period_2 to inside period_2" do
    fromTime = Time.new(2020, 11, 2, 16, 30)
    toTime = Time.new(2020, 11, 5, 16, 0)
    assert_equal 1*60*60 + 6.5*60*60 + 16*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "multiple days - no holidays - from inside period_1 to inside period_2" do
    fromTime = Time.new(2020, 11, 2, 9, 0)
    toTime = Time.new(2020, 11, 5, 15, 0)
    assert_equal 7.5*60*60 + 5.5*60*60 + 16*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "multiple days - no holidays - from before period_1 to after period_2" do
    fromTime = Time.new(2020, 11, 2, 5, 0)
    toTime = Time.new(2020, 11, 5, 21, 0)
    assert_equal 8*60*60 + 8*60*60 + 16*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "multiple days - no holidays - from after period_2 to before period_1" do
    fromTime = Time.new(2020, 11, 2, 20, 30)
    toTime = Time.new(2020, 11, 5, 5, 0)
    assert_equal 0 + 16*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "multiple days - no holidays - edge case - from at finish period_2 to at beginning period_1" do
    fromTime = Time.new(2020, 11, 2, 17, 30)
    toTime = Time.new(2020, 11, 5, 8, 30)
    assert_equal 0 + 16*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "multiple days - no holidays - edge case - from at finish period_2 to at beginning period_2" do
    fromTime = Time.new(2020, 11, 2, 17, 30)
    toTime = Time.new(2020, 11, 5, 13, 30)
    assert_equal 0*60*60 + 4*60*60 + 16*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end
  
  #
  # multiple days, with holidays in the middle
  # Choosing with attention fromTime and toTime, we must have same result as "two days no holidays" adding 2 working days
  #
  test "multiple days - with holidays in the middle - from inside period_1 to inside period_1" do
    fromTime = Time.new(2020, 10, 29, 9, 0)
    toTime = Time.new(2020, 11, 3, 10, 0)
    assert_equal 7.5*60*60 + 1.5*60*60 + 16*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "multiple days - with holidays in the middle - from inside period_2 to inside period_2" do
    fromTime = Time.new(2020, 10, 29, 16, 30)
    toTime = Time.new(2020, 11, 3, 16, 0)
    assert_equal 1*60*60 + 6.5*60*60 + 16*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "multiple days - with holidays in the middle - from inside period_1 to inside period_2" do
    fromTime = Time.new(2020, 10, 29, 9, 0)
    toTime = Time.new(2020, 11, 3, 15, 0)
    assert_equal 7.5*60*60 + 5.5*60*60 + 16*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "multiple days - with holidays in the middle - from before period_1 to after period_2" do
    fromTime = Time.new(2020, 10, 29, 5, 0)
    toTime = Time.new(2020, 11, 3, 21, 0)
    assert_equal 8*60*60 + 8*60*60 + 16*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "multiple days - with holidays in the middle - from after period_2 to before period_1" do
    fromTime = Time.new(2020, 10, 29, 20, 30)
    toTime = Time.new(2020, 11, 3, 5, 0)
    assert_equal 0 + 16*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "multiple days - with holidays in the middle - edge case - from at finish period_2 to at beginning period_1" do
    fromTime = Time.new(2020, 10, 29, 17, 30)
    toTime = Time.new(2020, 11, 3, 8, 30)
    assert_equal 0 + 16*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "multiple days - with holidays in the middle - edge case - from at finish period_2 to at beginning period_2" do
    fromTime = Time.new(2020, 10, 29, 17, 30)
    toTime = Time.new(2020, 11, 3, 13, 30)
    assert_equal 0*60*60 + 4*60*60 + 16*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

end
