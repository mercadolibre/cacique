ActionController::Routing::Routes.draw do |map|
  
  map.resource :session
  map.resources :execution_scaffolds, :active_scaffold => true  
  map.resources :circuits, :collection => { :ruby=>:get, :checkit=>:post, :getDataRecovery=>:get, :delete=>:get, :editName=>:get, :updateCircuit=>:get, :updateFile=>:get, :uploadFile=>:get, :error=>:get, :updateDataRecovery=>:get, :deleteDataRecovery=>:get, :get_suites_of_script =>:get, :rename=>:get, :script_tutorial=>:get}
  map.resources :circuits do |circuits|
    circuits.resources :case_templates, :active_scaffold => true do |case_templates|
      case_templates.resources :case_data, :active_scaffold => true
    end

  end
  
  map.resources :case_data
  map.resources :case_templates, :collection => { :create=>:get, :update_data=>:get, :update_status=>:get } 
  map.resources :categories, :collection => { :circuits_result => :get, :create=>:get, :delete=>:get, :edit=>:get, :update=>:get, :save_import_circuit=>:get, :import_circuit=>:get, :move=>:get, :move_save=>:get }
  map.resources :executions, :collection => { :retry_run=>:get, :show_snapshot=>:get, :stop=>:get }
  map.resources :homes, :collection => { :add_link=>:get, :delete_links=>:get, :about=> :get}
  map.resources :projects, :collection =>{ :assign=>:get, :get_all_projects=>:get, :get_my_projects=>:get,:edit => :get }
  map.resources :suites, :collection => { :sort=>:post, :index=>:get, :new_program=>:get, :import_suite=>:get, :save_import_suite=>:get, :delete_suite_case=>:get, :add_suite_case=>:get, :show=>:get, :suite_tutorial=>:get, :calendar=>:get}
  map.resources :suite_executions, :collection =>  { :workling_error=>:get, :index=>:get, :create => :post,:apply_filter=>:get, :export_popup=>:get, :refresh=>:get, :export=>:get, :get_report=>:get, :update_data=>:get, :show_model_filter=>:get, :show_cases_filter =>:get, :create=>:get, :update_suite_execution_status_index=>:get, :update_suite_execution_status_show=>:get }
  map.resources :users, :collection => { :password_recovery=>:get, :admin_panel=>:get , :show_user_form=>:get,:save=> :get, :update_permitions=>:get, :access_denied=>:get, :my_account=>:get }
  map.resources  :task_programs, :collection => {:index=>:get, :show_suites_of_project =>:get, :get_task_programs=>:get, :get_task_program_detail=>:get}
  map.resources  :queue_observers, :collection => {:quick_view => :get, :refresh=>:get, :show=>:get} 
  map.resources  :user_functions, :collection => { :show_move=>:get, :move=>:get}

  map.root :controller => 'sessions', :action => 'new'

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
