module CronsHelper
  def page_size_link per_page
    unless params[:per_page] == per_page.to_s
      params_aux = {:paginate=> per_page, :kind=>params[:kind]}
      params_aux = params_aux.merge({'filter' => params[:filter]}) if params[:filter]
      link_to per_page, crons_path(params_aux)
    else
      per_page
    end
  end  
end
