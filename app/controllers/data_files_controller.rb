class DataFilesController < ApplicationController


  def index 
    path = SHARED_DIRECTORY + "/project_#{params[:project_id]}/"
    @files = Dir.glob(path + "*")
  end


  def new

  end


  def create
      upload = Hash.new
      upload[:name]       = params['name']
      upload[:project_id] = params['project_id']
      upload[:fileUpload] = params['fileUpload'].read
      upload[:file_name]  = params['fileUpload'].original_filename
      if DataFile.create( upload )  
         redirect_to url_for(:action=>:index, :project_id=>params['project_id'])
      else
        flash.now[:error] = _('There is already a file with that name')
        render :action => 'new'
      end
  end

end
