module EvalEffectiveHoursOnlyPeriod1TestCommon

  # Black magic here ...
  # ref - http://schock.net/articles/2015/01/21/modules-with-rails-tests-share-behavior-minitest/
  
  extend ActiveSupport::Concern

  included do

    #
    # One day
    #
    test "Same work day - from inside period_1 to inside period_1 returns just the difference" do
      fromTime = Red_Counter::time_new_intz(2020, 11, 2, 9, 0)
      toTime = Red_Counter::time_new_intz(2020, 11, 2, 10, 0)
      assert_equal 1*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
    end

    test "Same work day - from inside period_1 to after period_1" do
      fromTime = Red_Counter::time_new_intz(2020, 11, 2, 9, 0)
      toTime = Red_Counter::time_new_intz(2020, 11, 2, 16, 0)
      assert_equal 3.5*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
    end

    test "Same work day - from before period_1 to before period_1: 0" do
      fromTime = Red_Counter::time_new_intz(2020, 11, 2, 5, 0)
      toTime = Red_Counter::time_new_intz(2020, 11, 2, 6, 0)
      assert_equal 0, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
    end

    test "Same work day - from before period_1 to inside period_1: shift from at 8:30" do
      fromTime = Red_Counter::time_new_intz(2020, 11, 2, 5, 0)
      toTime = Red_Counter::time_new_intz(2020, 11, 2, 11, 30)
      assert_equal 3*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
    end

    test "Same work day - from before period_1 to after period_1" do
      fromTime = Red_Counter::time_new_intz(2020, 11, 2, 5, 0)
      toTime = Red_Counter::time_new_intz(2020, 11, 2, 20, 30)
      assert_equal 4*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
    end

    test "Same holyday day - from inside period_1 to inside period_1 returns 0" do
      fromTime = Red_Counter::time_new_intz(2020, 11, 1, 9, 0)
      toTime = Red_Counter::time_new_intz(2020, 11, 1, 10, 0)
      assert_equal 0, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
    end

    test "Same holyday day - from before period_1 to after period_1 returns 0" do
      fromTime = Red_Counter::time_new_intz(2020, 11, 1, 5, 0)
      toTime = Red_Counter::time_new_intz(2020, 11, 1, 20, 0)
      assert_equal 0, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
    end

    test "Same work day - edge case - from at finish period_1 to after perios_1 returns 0" do
      fromTime = Red_Counter::time_new_intz(2020, 11, 2, 12, 30)
      toTime = Red_Counter::time_new_intz(2020, 11, 2, 13, 30)
      assert_equal 0, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
    end

    #
    # two days, no holidays
    #
    test "two days - no holidays - from inside period_1 to inside period_1" do
      fromTime = Red_Counter::time_new_intz(2020, 11, 2, 9, 0)
      toTime = Red_Counter::time_new_intz(2020, 11, 3, 10, 0)
      assert_equal 3.5*60*60 + 1.5*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
    end

    test "two days - no holidays - from inside period_1 to after period_1" do
      fromTime = Red_Counter::time_new_intz(2020, 11, 2, 9, 0)
      toTime = Red_Counter::time_new_intz(2020, 11, 3, 15, 0)
      assert_equal 3.5*60*60 + 4*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
    end

    test "two days - no holidays - from before period_1 to after period_1" do
      fromTime = Red_Counter::time_new_intz(2020, 11, 2, 5, 0)
      toTime = Red_Counter::time_new_intz(2020, 11, 3, 21, 0)
      assert_equal 4*60*60 + 4*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
    end

    test "two days - no holidays - from after period_1 to before period_1" do
      fromTime = Red_Counter::time_new_intz(2020, 11, 2, 20, 30)
      toTime = Red_Counter::time_new_intz(2020, 11, 3, 5, 0)
      assert_equal 0, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
    end

    test "two days - no holidays - edge case - from at finish period_1 to at beginning period_1" do
      fromTime = Red_Counter::time_new_intz(2020, 11, 2, 12, 30)
      toTime = Red_Counter::time_new_intz(2020, 11, 3, 8, 30)
      assert_equal 0, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
    end

    #
    # two days, with holidays in the middle
    # Choosing with attention fromTime and toTime, we must have same result as "two days no holidays"
    #
    test "two days - with holidays - from inside period_1 to inside period_1" do
      fromTime = Red_Counter::time_new_intz(2020, 10, 30, 9, 0)
      toTime = Red_Counter::time_new_intz(2020, 11, 2, 10, 0)
      assert_equal 3.5*60*60 + 1.5*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
    end

    test "two days - with holidays - from inside period_1 to after period_1" do
      fromTime = Red_Counter::time_new_intz(2020, 10, 30, 9, 0)
      toTime = Red_Counter::time_new_intz(2020, 11, 2, 15, 0)
      assert_equal 3.5*60*60 + 4*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
    end

    test "two days - with holidays - from before period_1 to after period_1" do
      fromTime = Red_Counter::time_new_intz(2020, 10, 30, 5, 0)
      toTime = Red_Counter::time_new_intz(2020, 11, 2, 21, 0)
      assert_equal 4*60*60 + 4*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
    end

    test "two days - with holidays - from after period_1 to before period_1" do
      fromTime = Red_Counter::time_new_intz(2020, 10, 30, 20, 30)
      toTime = Red_Counter::time_new_intz(2020, 11, 2, 5, 0)
      assert_equal 0, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
    end

    test "two days - with holidays - edge case - from at finish period_1 to at beginning period_1" do
      fromTime = Red_Counter::time_new_intz(2020, 10, 30, 12, 30)
      toTime = Red_Counter::time_new_intz(2020, 11, 2, 8, 30)
      assert_equal 0, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
    end
    
    #
    # multiple days, no holidays
    # Choosing with attention fromTime and toTime, we must have same result as "two days no holidays" adding 2 working days
    #
    test "multiple days - no holidays - from inside period_1 to inside period_1" do
      fromTime = Red_Counter::time_new_intz(2020, 11, 2, 9, 0)
      toTime = Red_Counter::time_new_intz(2020, 11, 5, 10, 0)
      assert_equal 3.5*60*60 + 1.5*60*60 + 8*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
    end

    test "multiple days - no holidays - from inside period_1 to after period_1" do
      fromTime = Red_Counter::time_new_intz(2020, 11, 2, 9, 0)
      toTime = Red_Counter::time_new_intz(2020, 11, 5, 15, 0)
      assert_equal 3.5*60*60 + 4*60*60 + 8*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
    end

    test "multiple days - no holidays - from before period_1 to after period_1" do
      fromTime = Red_Counter::time_new_intz(2020, 11, 2, 5, 0)
      toTime = Red_Counter::time_new_intz(2020, 11, 5, 21, 0)
      assert_equal 4*60*60 + 4*60*60 + 8*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
    end

    test "multiple days - no holidays - from after period_1 to before period_1" do
      fromTime = Red_Counter::time_new_intz(2020, 11, 2, 20, 30)
      toTime = Red_Counter::time_new_intz(2020, 11, 5, 5, 0)
      assert_equal 0 + 8*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
    end

    test "multiple days - no holidays - edge case - from at finish period_1 to at beginning period_1" do
      fromTime = Red_Counter::time_new_intz(2020, 11, 2, 12, 30)
      toTime = Red_Counter::time_new_intz(2020, 11, 5, 8, 30)
      assert_equal 0 + 8*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
    end
    
    #
    # multiple days, with holidays in the middle
    # Choosing with attention fromTime and toTime, we must have same result as "two days no holidays" adding 2 working days
    #
    test "multiple days - with holidays - from inside period_1 to inside period_1" do
      fromTime = Red_Counter::time_new_intz(2020, 10, 29, 9, 0)
      toTime = Red_Counter::time_new_intz(2020, 11, 3, 10, 0)
      assert_equal 3.5*60*60 + 1.5*60*60 + 8*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
    end

    test "multiple days - with holidays - from inside period_1 to after period_1" do
      fromTime = Red_Counter::time_new_intz(2020, 10, 29, 9, 0)
      toTime = Red_Counter::time_new_intz(2020, 11, 3, 15, 0)
      assert_equal 3.5*60*60 + 4*60*60 + 8*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
    end

    test "multiple days - with holidays - from before period_1 to after period_1" do
      fromTime = Red_Counter::time_new_intz(2020, 10, 29, 5, 0)
      toTime = Red_Counter::time_new_intz(2020, 11, 3, 21, 0)
      assert_equal 4*60*60 + 4*60*60 + 8*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
    end

    test "multiple days - with holidays - from after period_1 to before period_1" do
      fromTime = Red_Counter::time_new_intz(2020, 10, 29, 20, 30)
      toTime = Red_Counter::time_new_intz(2020, 11, 3, 5, 0)
      assert_equal 0 + 8*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
    end

    test "multiple days - with holidays - edge case - from at finish period_1 to at beginning period_1" do
      fromTime = Red_Counter::time_new_intz(2020, 10, 29, 12, 30)
      toTime = Red_Counter::time_new_intz(2020, 11, 3, 8, 30)
      assert_equal 0 + 8*60*60, Red_Counter::Helper.eval_effective_seconds(fromTime, toTime, Red_Counter::Config.new)
    end

  end

end
