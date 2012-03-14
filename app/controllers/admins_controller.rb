class AdminsController < ApplicationController
  
  def index
    permit "root" do
    end
  end

end
