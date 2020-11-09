# -*- encoding : utf-8 -*-
require File.expand_path('../../test_helper', __FILE__)
require_relative '../test_utils'

class SanitizeTimeTest < ActiveSupport::TestCase
  def setup
    TestUtils.set_workday_default
  end

  #
  # 2 periods
  #
  test "sunday -> monday 8:30" do
    sunday = Time.new(2020, 11, 1, 11, 10)
    monday = Time.new(2020, 11, 2, 8, 30)
    assert_equal monday, Red_Counter::Helper.sanitize_time(sunday, Red_Counter::Config.new, true)
    assert_equal monday, Red_Counter::Helper.sanitize_time(sunday, Red_Counter::Config.new, false )
  end

  test "thursday 11:10 -> thursday 11:10" do
    thursday = Time.new(2020, 11, 5, 11, 10)
    assert_equal thursday, Red_Counter::Helper.sanitize_time(thursday, Red_Counter::Config.new, true)
    assert_equal thursday, Red_Counter::Helper.sanitize_time(thursday, Red_Counter::Config.new, false)
  end

  test "thursday 15:10 -> thursday 15:10" do
    thursday = Time.new(2020, 11, 5, 15, 10)
    assert_equal thursday, Red_Counter::Helper.sanitize_time(thursday, Red_Counter::Config.new, true)
    assert_equal thursday, Red_Counter::Helper.sanitize_time(thursday, Red_Counter::Config.new, false)
  end

  test "thursday 13:10 -> thursday 12:30" do
    thursday_1310 = Time.new(2020, 11, 5, 13, 10)
    thursday_sanitized = Time.new(2020, 11, 5, 12, 30)    
    assert_equal thursday_sanitized, Red_Counter::Helper.sanitize_time(thursday_1310, Red_Counter::Config.new, true)
    assert_equal thursday_sanitized, Red_Counter::Helper.sanitize_time(thursday_1310, Red_Counter::Config.new, false)
  end

  test "thursday 5:10 -> thursday 8:30" do
    thursday_0510 = Time.new(2020, 11, 5, 05, 10)
    thursday_sanitized = Time.new(2020, 11, 5, 8, 30)    
    assert_equal thursday_sanitized, Red_Counter::Helper.sanitize_time(thursday_0510, Red_Counter::Config.new, true)
    assert_equal thursday_sanitized, Red_Counter::Helper.sanitize_time(thursday_0510, Red_Counter::Config.new, false)
  end

  test "thursday 20:10 -> thursday 17:30" do
    thursday_2010 = Time.new(2020, 11, 5, 20, 10)
    thursday_sanitized = Time.new(2020, 11, 5, 17, 30)    
    assert_equal thursday_sanitized, Red_Counter::Helper.sanitize_time(thursday_2010, Red_Counter::Config.new, true)
    assert_equal thursday_sanitized, Red_Counter::Helper.sanitize_time(thursday_2010, Red_Counter::Config.new, false)
  end

  #
  # Only period 1
  #
  test "only period_1: sunday -> monday 8:30" do
    TestUtils.set_workday_period_2 '', '', '', ''
    sunday = Time.new(2020, 11, 1, 11, 10)
    monday = Time.new(2020, 11, 2, 8, 30)
    assert_equal monday, Red_Counter::Helper.sanitize_time(sunday, Red_Counter::Config.new, true)
    assert_equal monday, Red_Counter::Helper.sanitize_time(sunday, Red_Counter::Config.new, false )
  end

  test "only period_1: thursday 11:10 -> thursday 11:10" do
    TestUtils.set_workday_period_2 '', '', '', ''
    thursday = Time.new(2020, 11, 5, 11, 10)
    assert_equal thursday, Red_Counter::Helper.sanitize_time(thursday, Red_Counter::Config.new, true)
    assert_equal thursday, Red_Counter::Helper.sanitize_time(thursday, Red_Counter::Config.new, false)
  end

  test "only period_1: thursday 15:10 -> thursday 12:30" do
    TestUtils.set_workday_period_2 '', '', '', ''
    thursday = Time.new(2020, 11, 5, 15, 10)
    thursday_sanitized = Time.new(2020, 11, 5, 12, 30)    
    assert_equal thursday_sanitized, Red_Counter::Helper.sanitize_time(thursday, Red_Counter::Config.new, true)
    assert_equal thursday_sanitized, Red_Counter::Helper.sanitize_time(thursday, Red_Counter::Config.new, false)
  end

  test "only period_1: thursday 13:10 -> thursday 12:30" do
    TestUtils.set_workday_period_2 '', '', '', ''
    thursday_1310 = Time.new(2020, 11, 5, 13, 10)
    thursday_sanitized = Time.new(2020, 11, 5, 12, 30)    
    assert_equal thursday_sanitized, Red_Counter::Helper.sanitize_time(thursday_1310, Red_Counter::Config.new, true)
    assert_equal thursday_sanitized, Red_Counter::Helper.sanitize_time(thursday_1310, Red_Counter::Config.new, false)
  end

  test "only period_1: thursday 5:10 -> thursday 8:30" do
    TestUtils.set_workday_period_2 '', '', '', ''
    thursday_0510 = Time.new(2020, 11, 5, 05, 10)
    thursday_sanitized = Time.new(2020, 11, 5, 8, 30)    
    assert_equal thursday_sanitized, Red_Counter::Helper.sanitize_time(thursday_0510, Red_Counter::Config.new, true)
    assert_equal thursday_sanitized, Red_Counter::Helper.sanitize_time(thursday_0510, Red_Counter::Config.new, false)
  end

  test "only period_1: thursday 20:10 -> thursday 12:30" do
    TestUtils.set_workday_period_2 '', '', '', ''
    thursday_2010 = Time.new(2020, 11, 5, 20, 10)
    thursday_sanitized = Time.new(2020, 11, 5, 12, 30)    
    assert_equal thursday_sanitized, Red_Counter::Helper.sanitize_time(thursday_2010, Red_Counter::Config.new, true)
    assert_equal thursday_sanitized, Red_Counter::Helper.sanitize_time(thursday_2010, Red_Counter::Config.new, false)
  end

  #
  # Only period 2
  #
  test "only period_2: sunday -> monday 13:30" do
    TestUtils.set_workday_period_1 '', '', '', ''
    sunday = Time.new(2020, 11, 1, 11, 10)
    monday = Time.new(2020, 11, 2, 13, 30)
    assert_equal monday, Red_Counter::Helper.sanitize_time(sunday, Red_Counter::Config.new, true)
    assert_equal monday, Red_Counter::Helper.sanitize_time(sunday, Red_Counter::Config.new, false )
  end

  test "only period_2: thursday 11:10 -> thursday 13:30" do
    TestUtils.set_workday_period_1 '', '', '', ''
    thursday = Time.new(2020, 11, 5, 11, 10)
    thursday_sanitized = Time.new(2020, 11, 5, 13, 30)
    assert_equal thursday_sanitized, Red_Counter::Helper.sanitize_time(thursday, Red_Counter::Config.new, true)
    assert_equal thursday_sanitized, Red_Counter::Helper.sanitize_time(thursday, Red_Counter::Config.new, false)
  end

  test "only period_2: thursday 15:10 -> thursday 15:10" do
    TestUtils.set_workday_period_1 '', '', '', ''
    thursday = Time.new(2020, 11, 5, 15, 10)
    thursday_sanitized = Time.new(2020, 11, 5, 15, 10)
    assert_equal thursday_sanitized, Red_Counter::Helper.sanitize_time(thursday, Red_Counter::Config.new, true)
    assert_equal thursday_sanitized, Red_Counter::Helper.sanitize_time(thursday, Red_Counter::Config.new, false)
  end

  test "only period_2: thursday 13:10 -> thursday 13:30" do
    TestUtils.set_workday_period_1 '', '', '', ''
    thursday_1310 = Time.new(2020, 11, 5, 13, 10)
    thursday_sanitized = Time.new(2020, 11, 5, 13, 30)    
    assert_equal thursday_sanitized, Red_Counter::Helper.sanitize_time(thursday_1310, Red_Counter::Config.new, true)
    assert_equal thursday_sanitized, Red_Counter::Helper.sanitize_time(thursday_1310, Red_Counter::Config.new, false)
  end

  test "only period_2: thursday 5:10 -> thursday 13:30" do
    TestUtils.set_workday_period_1 '', '', '', ''
    thursday_0510 = Time.new(2020, 11, 5, 05, 10)
    thursday_sanitized = Time.new(2020, 11, 5, 13, 30)    
    assert_equal thursday_sanitized, Red_Counter::Helper.sanitize_time(thursday_0510, Red_Counter::Config.new, true)
    assert_equal thursday_sanitized, Red_Counter::Helper.sanitize_time(thursday_0510, Red_Counter::Config.new, false)
  end

  test "only period_2: thursday 20:10 -> thursday 17:30" do
    TestUtils.set_workday_period_1 '', '', '', ''
    thursday_2010 = Time.new(2020, 11, 5, 20, 10)
    thursday_sanitized = Time.new(2020, 11, 5, 17, 30)    
    assert_equal thursday_sanitized, Red_Counter::Helper.sanitize_time(thursday_2010, Red_Counter::Config.new, true)
    assert_equal thursday_sanitized, Red_Counter::Helper.sanitize_time(thursday_2010, Red_Counter::Config.new, false)
  end

end
