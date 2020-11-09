# -*- encoding : utf-8 -*-
require File.expand_path('../../test_helper', __FILE__)
require_relative '../test_utils'
# require_relative 'eval_effective_hours_test_common'

class EvalEffectiveHoursTest < ActiveSupport::TestCase
  include EvalEffectiveHoursTestCommon

  def setup
    TestUtils.set_workday_default

    #
    # This test works with UTC
    #
    # @zone = ActiveSupport::TimeZone['Rome']
    # TestUtils.set_workday_timezone "Rome"
  end

end
