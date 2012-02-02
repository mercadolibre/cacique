class CronsController < ApplicationController

  def create
    Cron.regenerate
    redirect_to task_programs_path
  end

  def destroy
    Cron.remove(params[:id])
    #TODO: NEW VIEW 
    redirect_to task_programs_path
  end

end
