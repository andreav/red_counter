# -*- encoding : utf-8 -*-
match 'rc_config/(:action)',via: [:get, :post], :controller => 'rc_config'  

