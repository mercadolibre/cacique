module DelayedJobsHelper
  def page_size_link per_page
    unless params[:per_page] == per_page.to_s
      params[:filter] = {} if !params[:filter]
      link_to per_page, delayed_jobs_path( { 'filter' => params[:filter].merge({:paginate=> per_page}) } )
    else
      per_page
    end
  end
end


