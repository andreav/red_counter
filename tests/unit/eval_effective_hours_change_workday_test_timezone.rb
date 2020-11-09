# -*- encoding : utf-8 -*-
require File.expand_path('../../test_helper', __FILE__)
require_relative '../test_utils'

class EvalEffectiveHoursChangeWorkdayTestTimezone < ActiveSupport::TestCase
  include EvalEffectiveHoursChangeWorkdayTestCommon

  def setup
    TestUtils.set_workday_timezone "Rome"
    TestUtils.set_workday_period_1 8, 0, 12, 0
    TestUtils.set_workday_period_2 13, 0, 17, 0
  end

end
