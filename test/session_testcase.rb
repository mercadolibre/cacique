module SessionTestcase
	def create_user_if_not_exists( login, password )
		
		u = User.find_by_login(login)
		
		unless u
			print "creating user #{login}\n"
		
			
			u = User.new
			u.login = login
			u.password = password
			u.password_confirmation = password
			u.name = login
			u.email = "#{u.name}@host.com"
			raise "cannot create user #{login}" unless u.save
		end
	end
	
	def log_user( login )
		u = User.find_by_login(login)
		u.remember_me
	end
  
	def setup
		create_user_if_not_exists("guest","guest") 
	#	log_user("guest")
	end
  end
