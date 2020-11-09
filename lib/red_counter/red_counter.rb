module Red_Counter

    # Create a time in the timezone of the plugin 
    def self.time_new_intz year, month, day, hour, min
        tz = ActiveSupport::TimeZone[Setting['plugin_red_counter']['rc_wordday_timezone']]
        tz.parse("#{year}-#{month}-#{day} #{hour}:#{min}")
    end


    class Helper
        extend Redmine::Utils::DateCalculation

        #
        # Converts from any time to working times
        #
        def self.sanitize_time aTime, rc_cfg, is_start
            # WorkDay is expressed in a certain timezone => convert also aTime in the same timezone before comparing
            aTime = aTime.in_time_zone(rc_cfg.rc_wordday_timezone)
            # If occurs during not working days move to first valid time
            if non_working_week_days.include? aTime.to_date.cwday
                nwd = next_working_date(aTime.to_date)
                # return Time.new(nwd.year, nwd.month, nwd.day, rc_cfg.workday_start_time.hour, rc_cfg.workday_start_time.minute)
                return Red_Counter::time_new_intz(nwd.year, nwd.month, nwd.day, rc_cfg.workday_start_time.hour, rc_cfg.workday_start_time.minute)
            end

            aTod = Tod::TimeOfDay(aTime)

            # started before workday => workday_start_time
            if aTod < rc_cfg.workday_start_time
                # return Time.new(aTime.year, aTime.month, aTime.day, rc_cfg.workday_start_time.hour, rc_cfg.workday_start_time.minute)
                return Red_Counter::time_new_intz(aTime.year, aTime.month, aTime.day, rc_cfg.workday_start_time.hour, rc_cfg.workday_start_time.minute)
            # finished after workday => workday_end_time
            elsif aTod > rc_cfg.workday_end_time
                # return Time.new(aTime.year, aTime.month, aTime.day, rc_cfg.workday_end_time.hour, rc_cfg.workday_end_time.minute)
                return Red_Counter::time_new_intz(aTime.year, aTime.month, aTime.day, rc_cfg.workday_end_time.hour, rc_cfg.workday_end_time.minute)
            # started or finished during workday => ok
            elsif rc_cfg.workday_period_1.include?(aTod) || rc_cfg.workday_period_2.include?(aTod)
                return aTime
            # between period_1 and period_2
            else
                # return Time.new(aTime.year, aTime.month, aTime.day, rc_cfg.rc_end_wordday_time_1.hour, rc_cfg.rc_end_wordday_time_1.minute)
                return Red_Counter::time_new_intz(aTime.year, aTime.month, aTime.day, rc_cfg.rc_end_wordday_time_1.hour, rc_cfg.rc_end_wordday_time_1.minute)
            end
        end

        #
        # Counts workdays and not holiday
        #
        def self.eval_effective_seconds fromTime, toTime, rc_cfg
            startTime = sanitize_time fromTime, rc_cfg, true
            endTime = sanitize_time toTime, rc_cfg, false
            Rails.logger.info("eval_effective_seconds: from: #{fromTime} - to: #{toTime} - fromSani: #{startTime} - toSani: #{endTime} ")
            # STDOUT.puts("eval_effective_seconds: from: #{fromTime} - to: #{toTime} - fromSani: #{startTime} - toSani: #{endTime} ")

            startTod = Tod::TimeOfDay(startTime)
            endTod = Tod::TimeOfDay(endTime)
            periodShift = Tod::Shift.new(startTod, endTod)

            # same day: differece, except if period overlaps pause the subtract pause
            if(startTime.year == endTime.year && startTime.month == endTime.month && startTime.day == endTime.day)
                if periodShift.contains?(rc_cfg.workday_period_pause)
                    return periodShift.duration - rc_cfg.workday_period_pause.duration
                else
                    return periodShift.duration
                end
            end

            # different days: first day + last day + full working days in the middle
            # working_days counts day as at 00:00 (so it's like excluding to) => adding 1 day only to fromTime
            #       working_days(sunday, monday) == 0 --- working_days(monday, tuesday) == 1
            # Here starTime is already in the right timezone => create times in that timezone
            
            # firstDayEndTime = Time.new(startTime.year, startTime.month, startTime.day, rc_cfg.workday_end_time.hour, rc_cfg.workday_end_time.minute)
            firstDayEndTime = Red_Counter::time_new_intz(startTime.year, startTime.month, startTime.day, rc_cfg.workday_end_time.hour, rc_cfg.workday_end_time.minute)
            # lastDayStartTime = Time.new(endTime.year, endTime.month, endTime.day, rc_cfg.workday_start_time.hour, rc_cfg.workday_start_time.minute)
            lastDayStartTime = Red_Counter::time_new_intz(endTime.year, endTime.month, endTime.day, rc_cfg.workday_start_time.hour, rc_cfg.workday_start_time.minute)
            return eval_effective_seconds(startTime, firstDayEndTime, rc_cfg) +
                   eval_effective_seconds(lastDayStartTime, endTime, rc_cfg) +
                   working_days((startTime.to_date + 1), (endTime.to_date)) * rc_cfg.wordday_duration_seconds

        end

        #
        # Given a timeseries of state changes, eval counter periods
        #
        def self.process_issue_journal_details issueCounterResults, issue_jounal_details, counter_config, rc_cfg
            # STDOUT.puts( "issue #{issue_jounal_details.first.journal.journalized_id}" )

            # issue started already in counter state?
            issueCounterActive = false
            start_time = nil

            issue_jounal_details.each_with_index do |journal_det, index|

                Rails.logger.debug("  issue_id: #{issue_jounal_details.first.journal.journalized_id.to_s.rjust(4, ' ')} - journal_id: #{journal_det.id.to_s.rjust(3, ' ')} - from: #{journal_det.old_value.to_s.rjust(3, ' ')} to: #{journal_det.value.to_s.rjust(3, ' ')} on #{journal_det.journal.created_on}" )

                if index == 0
                    if journal_det.value.to_i == counter_config.status_id
                        issueCounterActive = true
                        start_time = journal_det.journal.created_on
                    end
                    next
                end

                enteringState = journal_det.value.to_i == counter_config.status_id && !issueCounterActive
                exitingState = journal_det.old_value.to_i == counter_config.status_id && journal_det.old_value.to_i != journal_det.value.to_i

                # last period, inside counter => flush counts
                if issueCounterActive && index == issue_jounal_details.count-1
                    exitingState = true
                end

                if enteringState && !issueCounterActive # manage consecutive counter periods
                    issueCounterActive = true
                    start_time = journal_det.journal.created_on
                    next
                end

                if exitingState && issueCounterActive
                    elapsedTime = self.eval_effective_seconds start_time, journal_det.journal.created_on, rc_cfg
                    self.add_elapsed_time issueCounterResults, journal_det.journal.journalized_id, elapsedTime, counter_config

                    issueCounterActive = false
                end

            end

        end

        # utility to sum counts
        def self.add_elapsed_time issueCounterResults, issue_id, elapsedTime_secs, counter_config
            custom_field_id = counter_config.custom_field_id
            elapsedTime = elapsedTime_secs
            if( counter_config.result_format == Red_Counter::Config::RESULT_FORMAT_MINUTES)
                elapsedTime = elapsedTime_secs / 60
            elsif( counter_config.result_format == Red_Counter::Config::RESULT_FORMAT_HOURS)
                # if the custom fiels is int, we cannot write  a float
                # elapsedTime = (elapsedTime_secs.to_f / (60*60)).round(1)
                elapsedTime = elapsedTime_secs / (60*60)
            end
            Rails.logger.info("    issue_id: #{issue_id} - counter: #{counter_config.description} - add_elapsed_time: #{elapsedTime}" )
 
            issue_entry = issueCounterResults[issue_id]
            if issue_entry == nil
                issueCounterResults[issue_id] = {}
                issueCounterResults[issue_id][custom_field_id] = elapsedTime
                return
            end
            if issue_entry.key?(custom_field_id)
                issue_entry[custom_field_id] += elapsedTime
                return
            end
            issue_entry[custom_field_id] = elapsedTime
        end

        def self.load_issues_query issues, projects, rc_config
            projects_enabled_ids = EnabledModule.where(name: 'red_counter').pluck(:project_id)
            projects_to_search_ids = projects_enabled_ids
            
            if projects
                projects_to_search_ids = []
                projects.each do |p_id|
                    if projects_enabled_ids.include?(p_id)
                        projects_to_search_ids << p_id
                    end
                end
            end

            trackers_to_search_ids = Tracker.includes(:custom_fields).where(custom_fields: {id: rc_config.custom_field_id}).select([:tracker_id])

            compute_issues_query = Issue.where(tracker_id: trackers_to_search_ids).where(project_id: projects_to_search_ids)
            if issues
                compute_issues_query = compute_issues_query.where(id: issues)
            end

            compute_issues_query.select([:id, :created_on, :status_id])
        end

        def self.build_fake_journals issue_id, issue_created_on, first_issue_state_value, last_issue_state_value, now
            first_and_last_kake_journals = []

            # Issue create DO NOT creates a journal => add fake journal to simplify computation
            fake_journal_det_start = JournalDetail.new( id: -1, journal_id: -1, property: 'attr', prop_key: 'status_id', old_value: -1, value: first_issue_state_value)
            fake_journal_det_start.journal = Journal.new( id: -1, journalized_id: issue_id, user_id: -1, created_on: issue_created_on)
            first_and_last_kake_journals << fake_journal_det_start

            # Also add a fake journal to extend last journal until now
            fake_journal_det_now = JournalDetail.new( id: -1, journal_id: -1, property: 'attr', prop_key: 'status_id', old_value: last_issue_state_value, value: last_issue_state_value)
            fake_journal_det_now.journal = Journal.new( id: -1, journalized_id: issue_id, user_id: -1, created_on: now)
            first_and_last_kake_journals << fake_journal_det_now

            first_and_last_kake_journals
        end

        def self.process_issues_batch issues_batch, currCounterCfg, rc_cfg, issueCounterResults, now

            # build issue_id --> created_on map / current state
            issue_creation_map = issues_batch.index_by(&:id)
            issues_batch_ids = issue_creation_map.keys

            journals_by_issue = JournalDetail.includes(:journal)                             \
                                .where(prop_key: 'status_id')                    \
                                .where("(old_value = ? or value = ?)", currCounterCfg.status_id, currCounterCfg.status_id)      \
                                .where(journals: {journalized_type: 'issue'})
                                .where(journals: {journalized_id: issues_batch_ids})
                                .order(:id)
                                .group_by {|j| j.journal.journalized_id }
            
            journals_by_issue.each do |issue_id, issue_jounal_details|

                Rails.logger.debug("Cfg: #{currCounterCfg.description} - Issue: #{issue_id} - Journal: #{issue_jounal_details}")

                first_state_value = issue_jounal_details.first.old_value.to_s
                last_state_value = issue_jounal_details.last.value
                first_and_last_fake_journals = build_fake_journals(issue_id, issue_creation_map[issue_id].created_on, first_state_value, last_state_value, now)

                issue_jounal_details.unshift(first_and_last_fake_journals[0])
                issue_jounal_details << first_and_last_fake_journals[1]

                process_issue_journal_details(issueCounterResults, issue_jounal_details, currCounterCfg, rc_cfg)
            end

            # New issues does not have journals => have not yet been processed
            no_journal_issues = issues_batch_ids - journals_by_issue.keys
            Rails.logger.debug("issues_batch_ids: #{issues_batch_ids}")
            Rails.logger.debug("processed_issued: #{journals_by_issue.keys}")
            Rails.logger.debug("no_journal_issues: #{no_journal_issues}")

            no_journal_issues.each do |issue_no_journals|
                Rails.logger.debug("Cfg: #{currCounterCfg.description} - Issue: #{issue_no_journals} - no_journal_issues")

                first_state_value = issue_creation_map[issue_no_journals].status_id.to_s
                last_state_value = issue_creation_map[issue_no_journals].status_id.to_s
                first_and_last_fake_journals = build_fake_journals(issue_no_journals, issue_creation_map[issue_no_journals].created_on, first_state_value, last_state_value, now)

                process_issue_journal_details(issueCounterResults, first_and_last_fake_journals, currCounterCfg, rc_cfg)

            end # no_journal_issues.each

        end  # process_issues_batch

        def self.upsert_counters issueCounterResults, rc_counters, rc_cfg
            
            # 1. load all issues and cfv in one query
            # 2. execute 1 query only for any difference
            # TODO - bulk insert/update? https://github.com/zdennis/activerecord-import ?

            issue_ids = issueCounterResults.keys        
            issues_with_cvs = Issue.includes(:custom_values).where(id: issue_ids)
            issues_with_cvs.each do |issue_with_cvs|
                issue_counters = issueCounterResults[issue_with_cvs.id]
                issue_counters.each do |cf_id, issue_counter_value|
                    issue_with_cvs.custom_field_values = { cf_id => issue_counter_value }
                end 
                issue_with_cvs.save
            end
        end


        #
        # main
        #
        def self.eval_time_spent_full_by_journals issues, projects, now = nil, upsert = true
            # STDOUT.puts("eval_time_spent_full_by_journals #{issues}")
            
            rc_cfg = Red_Counter::Config.new
            now = DateTime.now unless now != nil # use the same "now" for all issues

            countersElapsedTime = RcConfig.where(rc_type_id: Red_Counter::Config::RCTYPE_ELAPSED)
            issueCounterResults = {}  # issue[:issue_id][:cf_id] = result

            countersElapsedTime.each do |currCounterCfg|

                # Find issues with this counter and retrieve created_on and status_id (in case there is no journal)
                issue_query = load_issues_query(issues, projects, currCounterCfg)
                issue_query.find_in_batches(:batch_size => 100) do |issue_batch|
                    
                    process_issues_batch(issue_batch, currCounterCfg, rc_cfg, issueCounterResults, now)

                end

            end  # countersElapsedTime.each

            if upsert
                upsert_counters(issueCounterResults, countersElapsedTime, rc_cfg)
            end
            issueCounterResults

        end # eval_time_spent_full_by_journals

    end # class
end # module
