# -*- encoding : utf-8 -*-
# Load the normal Rails helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

class RedCounter::TestCase
    def self.create_fixtures(fixtures_directory, table_names, class_names = {})
      if ActiveRecord::VERSION::MAJOR >= 4
        ActiveRecord::FixtureSet.create_fixtures(fixtures_directory, table_names, class_names = {})
      else
        ActiveRecord::Fixtures.create_fixtures(fixtures_directory, table_names, class_names = {})
      end
    end
  
    # def self.prepare
    #   Role.find(1, 2, 3, 4).each do |r|
    #     r.permissions << :manage_public_agile_queries
    #     r.permissions << :add_agile_queries
    #     r.permissions << :view_agile_queries
    #     r.permissions << :agile_versions
    #     r.save
    #   end
    # end
end