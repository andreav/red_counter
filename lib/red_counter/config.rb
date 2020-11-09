module Red_Counter

    class Config
        # DEFAULT_INTERVAL = 30
      
        def logger
           Rails.logger if Rails.logger.info?
        end

        # -----------------------------------
        # model constants
        # -----------------------------------

        RCTYPE_ELAPSED = 1
        RCTYPE_OCCURRENCES = 2

        RESULT_FORMAT_SECONDS = 'seconds'
        RESULT_FORMAT_MINUTES = 'minutes'
        RESULT_FORMAT_HOURS = 'hours'

        def rc_type_fields_for_select
            return [
                [I18n.translate('rc_type_duration'), RCTYPE_ELAPSED],
                [I18n.translate('rc_type_occurrences'), RCTYPE_OCCURRENCES]
            ]
        end

        def rc_result_format_fields_for_select
            return [
                [I18n.translate('rc_result_format_seconds'), RESULT_FORMAT_SECONDS],
                [I18n.translate('rc_result_format_minutes'), RESULT_FORMAT_MINUTES],
                [I18n.translate('rc_result_format_hours'), RESULT_FORMAT_HOURS]
            ]
        end    

        # -----------------------------------
        # Config management
        # -----------------------------------

        def rc_wordday_timezone_code
            unless @rc_wordday_timezone_code
                @rc_wordday_timezone_code = Setting['plugin_red_counter']['rc_wordday_timezone']
            end
            @rc_wordday_timezone_code
        end

        def rc_wordday_timezone
            unless @rc_wordday_timezone
                @rc_wordday_timezone = ActiveSupport::TimeZone[rc_wordday_timezone_code]
            end
            @rc_wordday_timezone
        end        

        def is_date_config_valid_1
            return (rc_start_wordday_time_1 != nil && rc_end_wordday_time_1 != nil && rc_end_wordday_time_1 > rc_start_wordday_time_1)
        end
        def is_date_config_valid_2
            return (rc_start_wordday_time_2 != nil && rc_end_wordday_time_2 != nil && rc_end_wordday_time_2 > rc_start_wordday_time_2)
        end

        def is_date_config_valid
            return is_date_config_valid_1 || is_date_config_valid_2
        end

        def read_workday_time_cfg startend, pos
            rc_start_wordday_time_hour = Setting['plugin_red_counter']["rc_#{startend}_wordday_time_hour_#{pos}"]
            rc_start_wordday_time_minutes = Setting['plugin_red_counter']["rc_#{startend}_wordday_time_minutes_#{pos}"].blank? ? 0 : Setting['plugin_red_counter']["rc_#{startend}_wordday_time_minutes_#{pos}"]
            rc_start_wordday_time = rc_start_wordday_time_hour.blank? ? nil : Tod::TimeOfDay.new(rc_start_wordday_time_hour, rc_start_wordday_time_minutes, 0)
            # logger.info("red_counter: rc_#{startend}_wordday_time_#{pos} #{rc_start_wordday_time}") if logger
            return rc_start_wordday_time
        end

        def rc_start_wordday_time_1
          unless @rc_start_wordday_time_1
            @rc_start_wordday_time_1 = read_workday_time_cfg "start", 1
          end
          @rc_start_wordday_time_1
        end

        def rc_end_wordday_time_1
            unless @rc_end_wordday_time_1
              @rc_end_wordday_time_1 = read_workday_time_cfg "end", 1
            end
            @rc_end_wordday_time_1
        end
        
        def rc_start_wordday_time_2
            unless @rc_start_wordday_time_2
              @rc_start_wordday_time_2 = read_workday_time_cfg "start", 2
            end
            @rc_start_wordday_time_2
          end
  
          def rc_end_wordday_time_2
              unless @rc_end_wordday_time_2
                @rc_end_wordday_time_2 = read_workday_time_cfg "end", 2
              end
              @rc_end_wordday_time_2
          end
    
        def workday_start_time
            if is_date_config_valid_1
                return rc_start_wordday_time_1
            elsif is_date_config_valid_2
                return rc_start_wordday_time_2
            else
                return nil
            end
        end

        def workday_end_time
            if is_date_config_valid_2
                return rc_end_wordday_time_2
            elsif is_date_config_valid_1
                return rc_end_wordday_time_1
            else
                return nil
            end
        end

        def workday_period_1
            if is_date_config_valid_1
                return Tod::Shift.new(rc_start_wordday_time_1, rc_end_wordday_time_1)
            else
                return Tod::Shift.new(0, 0)
            end
        end

        def workday_period_2
            if is_date_config_valid_2
                return Tod::Shift.new(rc_start_wordday_time_2, rc_end_wordday_time_2)
            else
                return Tod::Shift.new(0, 0)
            end
        end

        def workday_period
            return Tod::Shift.new(workday_start_time, workday_end_time)
        end

        def workday_period_pause
            if is_date_config_valid_1 && is_date_config_valid_2
                return Tod::Shift.new(rc_end_wordday_time_1, rc_start_wordday_time_2)
            else
                return Tod::Shift.new(0, 0)
            end
        end

        def wordday_duration_seconds
            # unless @rc_wordday_seconds
            #     @rc_wordday_seconds = nil
            #     return nil  unless is_date_config_valid
                
            #     @rc_wordday_seconds = 0
            #     if is_date_config_valid_1
            #         @rc_wordday_seconds += Tod::Shift.new(rc_start_wordday_time_1, rc_end_wordday_time_1).duration
            #     end
            #     if is_date_config_valid_2
            #         @rc_wordday_seconds += Tod::Shift.new(rc_start_wordday_time_2, rc_end_wordday_time_2).duration
            #     end
            # end
            # return @rc_wordday_seconds
            unless @wordday_duration_seconds
                @wordday_duration_seconds = workday_period.duration - workday_period_pause.duration
            end
            return @wordday_duration_seconds
        end

    end

end