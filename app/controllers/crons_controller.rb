class CronsController < ApplicationController

  def index
    #Values for filter
    Suite
    @projects     = Project.all
    @users        = User.all   
    @project_id   = params[:project_id] = (params[:filter] && params[:filter][:project_id])? params[:filter][:project_id].to_i : params[:project_id].to_i

    #Suites
    suites_ids = Rails.cache.fetch("project_suites_#{@project_id}"){Project.find(@project_id).suite_ids}
    @suites    = Suite.find(suites_ids)  

    @crons = Cron.filter(params)
  end
  
  def create
    Cron.regenerate
    redirect_to crons_path
  end

end
