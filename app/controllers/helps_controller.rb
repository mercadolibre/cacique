class HelpsController < ApplicationController

  def show
    #1: script_tutorial
    #2: suite_tutorial
    #3: ruby help
    @help = params[:id].to_i
  end



end
