# -*- encoding : utf-8 -*-
require File.expand_path('../../test_helper', __FILE__)
require_relative '../test_utils'
# require_relative 'eval_effective_hours_test_common'

class EvalEffectiveHoursTestTimezone < ActiveSupport::TestCase
  include EvalEffectiveHoursTestCommon

  def setup
    TestUtils.set_workday_default
    
    #
    # This test works with Rome Timezone
    #
    TestUtils.set_workday_timezone "Rome"
  end

  test "Timezone::Rome - utc is before starting hours, timezone is after starting hours. Must be used timezone for the counter" do
    fromTime = Red_Counter::time_new_intz(2020, 11, 9, 9, 0)
    toTime = Red_Counter::time_new_intz(2020, 11, 9, 9, 30)

    assert_equal 0.5*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

  test "Timezone::Rome - counter 24h - counter must use timezone time" do
    TestUtils.set_workday_period_1 '00', '00', '24', '00'
    TestUtils.set_workday_period_2 '', '', '', ''

    fromTime = Red_Counter::time_new_intz(2020, 11, 9, 0, 30)
    toTime = Red_Counter::time_new_intz(2020, 11, 9, 9, 30)
    assert_equal 9*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
  end

end
