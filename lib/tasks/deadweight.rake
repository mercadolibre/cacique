begin
  require 'deadweight'
rescue LoadError
end
desc "run Deadweight  (busca css sin usar:  script/server debe estar levantado)"
task :deadweight do
dw = Deadweight.new
#dw.stylesheets = ['/stylesheets/default.css','/stylesheets/home.css','/stylesheets/active_scaffold_overrides.css','/stylesheets/menu.css']  
dw.stylesheets = ['/stylesheets/default.css','/stylesheets/menu.css']
dw.pages = ['/']  
puts dw.run  
end 
