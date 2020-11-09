require_dependency 'issue'

module RedCounter
  module Patches
    module IssuePatch

      def self.included(base)
        STDOUT.puts("RedCounter::Patches::IssuePatch included")

        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)

        base.class_eval do
            
            # has_many :tabella, :dependent => :destroy

            before_save :update_rc_counters, if: :status_id_changed?

        end
      end

      module ClassMethods
      end

      module InstanceMethods
      end

      private
      
        def update_rc_counters
            # STDOUT.puts("#{self.saved_changes}")     # for after_save
            # STDOUT.puts("#{self.changes}")           # for before_save

            # Find if I need to count state occurrences for this new state
            rcConfig = RcConfig.where({status_id: self.status_id, rc_type_id: Red_Counter::Config::RCTYPE_OCCURRENCES}).first
            if rcConfig != nil  
                custom_field_result = self.custom_field_values.select{ |cfv| cfv.custom_field.id == rcConfig.custom_field_id }.first            
                if custom_field_result != nil
                    custom_field_result.value  = (custom_field_result.value.to_i + 1).to_s
                end
            end
        end
    end
  end
end

unless Issue.included_modules.include?(RedCounter::Patches::IssuePatch)
  Issue.send(:include, RedCounter::Patches::IssuePatch)
end
