class RcConfig < ActiveRecord::Base
    unloadable
    
    # In this custom field put the computation (count time || count occurrences) when issue in in this status
    # | customfield | op | status |

    belongs_to :custom_field
    # belongs_to :rc_type
    belongs_to :status, :class_name => 'IssueStatus'

    validates_presence_of :custom_field
    validates_presence_of :rc_type_id
    validates_presence_of :status
  
  end