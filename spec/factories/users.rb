Factory.define :user do |u|
  u.add_attribute :name, "test" 
  u.add_attribute :login, "test" 
  u.add_attribute :email, "test@test.com"
  u.add_attribute :crypted_password, "c96783c08673aa86fde9847c9e27334d640aaa22"
  u.add_attribute :salt, "8e0d0e37e3f5452e73bca5113e726f1a3a958805" 
  u.add_attribute :remember_token, nil
  u.add_attribute :remember_token_expires_at, nil
  u.add_attribute :active, false
  u.add_attribute :language, "en_US"
end
