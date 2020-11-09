class RcConfigController < ApplicationController
    unloadable
   
    before_action :require_admin
    before_action :load_lookups
        
    def index            

    end
    
    def new
  
    end
    
    def edit
      @rc_configs = RcConfig.all 
    end    
    
    def update
    #   @wl_national_holiday = WlNationalHoliday.find(params[:id]) rescue nil 
    
    #   respond_to do |format|
    #     if @wl_national_holiday.update_attributes(wl_national_holiday_params)
    #       format.html { redirect_to(:action => 'index', :notice => 'Holiday was successfully updated.', :params => { :year =>params[:year]} ) }
    #       format.xml  { head :ok }
    #     else
    #       format.html { 
    #         flash[:error] = "<ul>" + @wl_national_holiday.errors.full_messages.map{|o| "<li>" + o + "</li>" }.join("") + "</ul>"
    #         render :action => "edit" }
    #       format.xml  { render :xml => @wl_national_holiday.errors, :status => :unprocessable_entity }
    #     end
    #   end
    end
    
    def update_all
        # STDOUT.puts("UPdate_alllllllllll: #{pp(params)}")
        
        @error = false
        params[:rc_configs].each do |key, config| 
  
          @rcConfig = RcConfig.find_by_id(key)
          if @rcConfig != nil
            # STDOUT.puts("                : #{pp(@rcConfig)}")

            @rcConfig.description = config[:description]
            @rcConfig.custom_field_id = config[:custom_field_id]
            @rcConfig.rc_type_id = config[:rc_type_id]
            @rcConfig.status_id = config[:status_id]
            @rcConfig.result_format = config[:result_format]
            
            if ! @rcConfig.save
            # STDOUT.puts("                : error on save")
            @error = true
            end    
          else
            # STDOUT.puts("                : error")
            @error = true
          end
         
        end
                 
        respond_to do |format|
          if ! @error
            flash[:notice] = l(:rc_configs_updated)
            format.html { redirect_to :action => :edit }
          else
            format.html { render :action => 'edit' }
          end
        end
  
    end    
  
    def create
      # raise Unauthorized unless User.current.is_admin?

      @rcConfig = RcConfig.new
      @rcConfig.description = params[:rc_config][:description]
      @rcConfig.custom_field_id = params[:rc_config][:custom_field_id]
      @rcConfig.rc_type_id = params[:rc_config][:rc_type_id]
      @rcConfig.status_id = params[:rc_config][:status_id]
      @rcConfig.result_format = params[:rc_config][:result_format]

      respond_to do |format|
        if @rcConfig.save
          flash[:notice] = l(:rc_config_created)
          format.html { redirect_to :action => :edit }
        else
          format.html { render :action => 'new' }
        end
      end


    end
    
    def destroy
      @rcConfig = RcConfig.find(params[:id])
      @rcConfig.destroy

      flash[:notice] = l(:rc_configs_deleted)

      redirect_to :back
    
    end
  
    def schedule_eval_time_spent_full_by_journals

      EvalTimeSpentJob.perform_later(nil, nil)

      flash[:notice] = l(:rc_eval_time_spent_job_scheduled)

      redirect_to :back
    
    end

  private
  
    # def check_edit_rights
    #   right = User.current.allowed_to?(:edit_redcounter_config, @projects.first)
    #   if !right
    #     flash[:error] = translate 'no_right'
    #     redirect_to :back
    #   end
    # end

    def load_lookups
      custom_fields = CustomField.where(:type => 'IssueCustomField', :field_format => ['float', 'int'])
      @custom_fields_for_select = custom_fields.collect{|c| [c.name, c.id]}

      # @type_fields_for_select = RcType.all.collect{|t| [t.description, t.id]}
      @type_fields_for_select = Red_Counter::Config.new.rc_type_fields_for_select
      
      @result_format_fields_for_select = Red_Counter::Config.new.rc_result_format_fields_for_select

      @status_fields_for_select = IssueStatus.all.collect{ |s| [s.name, s.id] }
    end
      
end
  