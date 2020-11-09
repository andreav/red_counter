require "active_job"


class EvalTimeSpentJob < ActiveJob::Base
    queue_as :default

    def perform(issues, projects)
        issues = issues.split(',').map { |s| s.to_i } rescue nil
        projects = projects.split(',').map { |s| s.to_i } rescue nil

        Red_Counter::Helper.eval_time_spent_full_by_journals issues, projects, DateTime.now, true
    end
end
