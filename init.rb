# require 'redmine'
require 'tod'

Redmine::Plugin.register :red_counter do
  name "Redmine Counter"
  author 'andreav'
  description 'Count redmine SLAs and events'
  version '0.1'
  url ''
  author_url 'mailto:andreav.pub'

  requires_redmine version_or_higher: '4.1'

  settings :default => {
    'rc_wordday_timezone' => 'UTC',
    'rc_start_wordday_time_hour_1' => '8',
    'rc_start_wordday_time_minutes_1' => '30',
    'rc_end_wordday_time_hour_1' => '12',
    'rc_end_wordday_time_minutes_1' => '30',
    'rc_start_wordday_time_hour_2' => '13',
    'rc_start_wordday_time_minutes_2' => '30',
    'rc_end_wordday_time_hour_2' => '17',
    'rc_end_wordday_time_minutes_2' => '30',
  },
  :partial => 'settings/red_counter_settings'

  menu :admin_menu, :red_counter, { controller: 'rc_config', action: 'edit' }, caption: :red_counter, html: { class: 'icon icon-hourglass' }

  project_module :red_counter do
    permission :view_redcounter_config, :rc_config => :show
    permission :edit_redcounter_config, :rc_config => [:create, :update, :destroy ]
  end
end

class RedmineToolbarHookListener < Redmine::Hook::ViewListener
  def view_layouts_base_html_head(context)
    # javascript_include_tag('sutcomjs', :plugin => :red_counter ) +
    stylesheet_link_tag('style', :plugin => :red_counter )
  end
end
