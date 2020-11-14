# Once test db is setup (see COMMANDS.md)
# Load defaul data and launch test shell

# 1. cd /opt/bitnami/redmine
# 2. RAILS_ENV=test bundle exec rake redmine:load_default_data
# 3. bundle exec rails console --sandbox -e test
    
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

cf_occur_in_new_and_assigned = create_custom_filed 'IssueCustomField', 'Time_In_New_And_Assigned', 'float', 1
rcConfig_Occur_In_Assigned = RcConfig.create(description: "New and Assigned Counter", status_id: 1, rc_type_id: Red_Counter::Config::RCTYPE_OCCURRENCES, custom_field_id: cf_occur_in_new_and_assigned.id)
rcConfig_Occur_In_Assigned = RcConfig.create(description: "New and Assigned Counter", status_id: 2, rc_type_id: Red_Counter::Config::RCTYPE_OCCURRENCES, custom_field_id: cf_occur_in_new_and_assigned.id)

i1 = create_issue(Time.new(2020, 11, 2, 9, 00), "RedCounter 1: new -> assigned -> resolved", 1)
is = Issue.includes(:custom_values).find_by(id: i1.id)
is.custom_value_for(cf_occur_in_new_and_assigned.id)
is.custom_field_values = { cf_occur_in_new_and_assigned.id => 1 }
is.save
is.reload
is.custom_value_for(cf_occur_in_new_and_assigned.id)
is.custom_value_for(cf_occur_in_new_and_assigned.id).value.to_f == 1.to_f

is.custom_field_values = { cf_occur_in_new_and_assigned.id => 1 }
is.save
