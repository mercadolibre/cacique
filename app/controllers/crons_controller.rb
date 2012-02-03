class CronsController < ApplicationController

  def index
  end
  
  def create
    #TODO: utilizar este metodo para al creación de un cron 
    # o de todos (regenerate)
    Cron.regenerate
    redirect_to task_programs_path
  end

  def destroy
    Cron.remove(params[:id])
    #TODO: NEW VIEW 
    redirect_to task_programs_path
  end

end
