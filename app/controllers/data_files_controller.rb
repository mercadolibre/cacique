class DataFilesController < ApplicationController


  def index 
    path = SHARED_DIRECTORY + "/project_#{params[:project_id]}/*"
    @files = Dir.glob(path).collect{|file| file.gsub(SHARED_DIRECTORY, "")}
  end


  def new

  end


  def create
      upload = Hash.new
      upload[:name]       = params['name']
      upload[:project_id] = params['project_id']
      upload[:fileUpload] = params['fileUpload'].read
      upload[:file_name]  = params['fileUpload'].original_filename
      begin
         if DataFile.create( upload ) 
           redirect_to url_for(:action=>:index, :project_id=>params['project_id'])
         else
            flash.now[:error] = _('There is already a file with that name')
            render :action => 'new'
         end
      rescue Exception => e
          flash.now[:error] =  e.message + "/n/n An error occurred, please check that SHARED_DIRECTORY is correctly defined in the file /config/cacique_conf"
          render :action => 'new'        
      end
  end

end
