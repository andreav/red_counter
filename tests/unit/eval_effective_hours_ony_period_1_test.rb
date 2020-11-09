# -*- encoding : utf-8 -*-
require File.expand_path('../../test_helper', __FILE__)
require_relative '../test_utils'

class EvalEffectiveHoursOnlyPeriod1Test < ActiveSupport::TestCase
  include EvalEffectiveHoursOnlyPeriod1TestCommon

  def setup
    TestUtils.set_workday_default

    #
    # This test works with UTC
    #
    # @zone = ActiveSupport::TimeZone['Rome']
    # TestUtils.set_workday_timezone "Rome"

    TestUtils.set_workday_period_2 '', '', '', ''
  end

end
