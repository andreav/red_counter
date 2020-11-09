class TestUtils

    #
    # Config
    #
    def self.set_workday_default
        set_workday_period_1 8, 30, 12, 30
        set_workday_period_2 13, 30, 17, 30
    end
   
    def self.set_workday_period_1(start_hour, start_minutes, end_hour, end_minutes)
        Setting['plugin_red_counter']['rc_start_wordday_time_hour_1'] = start_hour.to_s
        Setting['plugin_red_counter']['rc_start_wordday_time_minutes_1'] = start_minutes.to_s
        Setting['plugin_red_counter']['rc_end_wordday_time_hour_1'] = end_hour.to_s
        Setting['plugin_red_counter']['rc_end_wordday_time_minutes_1'] = end_minutes.to_s
    end

    def self.set_workday_period_2(start_hour, start_minutes, end_hour, end_minutes)
        Setting['plugin_red_counter']['rc_start_wordday_time_hour_2'] = start_hour.to_s
        Setting['plugin_red_counter']['rc_start_wordday_time_minutes_2'] = start_minutes.to_s
        Setting['plugin_red_counter']['rc_end_wordday_time_hour_2'] = end_hour.to_s
        Setting['plugin_red_counter']['rc_end_wordday_time_minutes_2'] = end_minutes.to_s
    end

    #
    # Functional tests
    #
    def self.enable_module_on_project proj_id
        EnabledModule.create(:project_id => proj_id, :name => 'red_counter')
    end
    def self.disable_module_on_project proj_id
        EnabledModule.where(:project_id => proj_id, :name => 'red_counter').destroy_all
    end
    
    def self.create_custom_filed type, name, field_format, tracker_id
        cf = CustomField.create(type: type, name: name, field_format: field_format, is_filter: 1, is_for_all: 1 )
        t = Tracker.find(tracker_id)
        cf.trackers << t
        cf
    end

    def self.create_issue(created_on, subject, user_id, project_id = 1)
        i = Issue.create(:tracker_id => 1, 
                         :project_id => project_id, 
                         :subject => subject, 
                         :status_id => 1, 
                         :created_on => created_on, 
                         :updated_on => created_on, 
                         :author_id => user_id)
                        #  :custom_fields => [{id: 2, value: "IT"}]
        i.created_on = created_on
        i.updated_on = created_on
        i.save
        i
    end

    def self.move_issue_to_new(issue, change_date)
        move_issue_to_state issue, "New", change_date
    end

    def self.move_issue_to_assigned(issue, change_date)
        move_issue_to_state issue, "Assigned", change_date
    end

    def self.move_issue_to_resolved(issue, change_date)
        move_issue_to_state issue, "Resolved", change_date
    end

    def self.fake_journal_det status_id_old, status_id_new, created_on
        fake_journal_det = JournalDetail.new( id: -1, journal_id: -1, property: 'attr', prop_key: 'status_id', old_value: status_id_old, value: status_id_new)
        fake_journal_det.journal = Journal.new( id: -1, journalized_id: -1, user_id: -1, created_on: created_on)
        fake_journal_det
    end

    private

    def self.move_issue_to_state(issue, state_name, change_date)
        # journal = issue.init_journal(User.current)
        # journal.update_attributes(:created_on => change_date)
        status = IssueStatus.where(:name => state_name).first
        old_status_id = issue.status_id
        issue.update_attributes(:status_id => status.id, :updated_on => change_date)
        issue.journals.create!(:user_id => 1, :created_on => change_date)
        issue.journals.last.details.create!(:property  => 'attr',
                                            :prop_key  => 'status_id',
                                            :old_value => old_status_id,
                                            :value     => status.id)
        issue.reload
    end

end