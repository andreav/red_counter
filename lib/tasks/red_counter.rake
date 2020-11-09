namespace :red_counter do

    desc "Eval Time Spent according to RedCounter configurations"
    task eval_time_spent: :environment do
        issues = ENV['ISSUES'].split(',').map { |s| s.to_i } rescue nil
        projects = ENV['PROJECTS'].split(',').map { |s| s.to_i } rescue nil

        Red_Counter::Helper.eval_time_spent_full_by_journals issues, projects, DateTime.now, true
    end
  
    desc "(Preview) - Eval Time Spent according to RedCounter configurations"
    task eval_occurrences: :environment do
        issues = ENV['ISSUES'].split(',').map { |s| s.to_i } rescue nil
        projects = ENV['PROJECTS'].split(',').map { |s| s.to_i } rescue nil

        res = Red_Counter::Helper.eval_time_spent_full_by_journals issues, projects, DateTime.now, false
        STDOUT.puts res
    end
  
  end
  