module DelayedJobsHelper
  def page_size_link per_page
    unless params[:per_page] == per_page.to_s
      index_path = params[:filter]? delayed_jobs_path( { 'filter' => params[:filter].merge({:paginate=> per_page}) } ) : delayed_jobs_path
      link_to per_page, index_path
    else
      per_page
    end
  end
end
