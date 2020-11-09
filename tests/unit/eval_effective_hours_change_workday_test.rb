# -*- encoding : utf-8 -*-
require File.expand_path('../../test_helper', __FILE__)
require_relative '../test_utils'

class EvalEffectiveHoursChangeWorkdayTest < ActiveSupport::TestCase
  def setup
    TestUtils.set_workday_period_1 8, 0, 12, 0
    TestUtils.set_workday_period_2 13, 0, 17, 0
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

  test "Same work day - from before period_1 to inside period_1: shift from at 8:00" do
    fromTime = Time.new(2020, 11, 2, 5, 0)
    toTime = Time.new(2020, 11, 2, 11, 30)
    assert_equal 3.5*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "Same work day - from before period_1 to inside pause between: shift from at 8:00, shift to at 12:00" do
    fromTime = Time.new(2020, 11, 2, 5, 0)
    toTime = Time.new(2020, 11, 2, 12, 30)
    assert_equal 4*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "Same work day - from before period_1 to inside period_2: shift from at 8:00 - do not count pause" do
    fromTime = Time.new(2020, 11, 2, 5, 0)
    toTime = Time.new(2020, 11, 2, 14, 30)
    assert_equal 4*60*60 + 1.5*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "Same work day - from before period_1 to after period_2: shift from at 8:00, shift to at 17:00 - do not count pause" do
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
    fromTime = Time.new(2020, 11, 2, 12, 00)
    toTime = Time.new(2020, 11, 2, 13, 00)
    assert_equal 0, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "Same Day - edge case - from at finish period_1 to at finish period_2" do
    fromTime = Time.new(2020, 11, 2, 12, 00)
    toTime = Time.new(2020, 11, 2, 17, 00)
    assert_equal 4*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

end
