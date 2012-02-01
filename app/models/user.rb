# == Schema Information
# Schema version: 20110630143837
#
# Table name: users
#
#  id                        :integer(4)      not null, primary key
#  login                     :string(255)
#  name                      :string(255)
#  email                     :string(255)
#  crypted_password          :string(40)
#  salt                      :string(40)
#  created_at                :datetime
#  updated_at                :datetime
#  remember_token            :string(255)
#  remember_token_expires_at :datetime
#  active                    :boolean(1)      not null
#  language                  :string(5)       default("en_US")
#  api_key                   :string(40)      default("")
#

 #
 #  @Authors:
 #      Brizuela Lucia                  lula.brizuela@gmail.com
 #      Guerra Brenda                   brenda.guerra.7@gmail.com
 #      Crosa Fernando                  fernandocrosa@hotmail.com
 #      Branciforte Horacio             horaciob@gmail.com
 #      Luna Juan                       juancluna@gmail.com
 #
 #  @copyright (C) 2010 MercadoLibre S.R.L
 #
 #
 #  @license        GNU/GPL, see license.txt
 #  This program is free software: you can redistribute it and/or modify
 #  it under the terms of the GNU General Public License as published by
 #  the Free Software Foundation, either version 3 of the License, or
 #  (at your option) any later version.
 #
 #  This program is distributed in the hope that it will be useful,
 #  but WITHOUT ANY WARRANTY; without even the implied warranty of
 #  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 #  GNU General Public License for more details.
 #
 #  You should have received a copy of the GNU General Public License
 #  along with this program.  If not, see http://www.gnu.org/licenses/.
 #
require 'digest/sha1'
class User < ActiveRecord::Base
  has_many :circuits
  has_many :case_templates
  has_many :executions, :dependent => :destroy
  has_one  :home, :dependent => :destroy
  has_many :notes, :dependent => :destroy
  has_one  :user_configuration
  has_many :project_users
  has_many :projects, :through => :project_users
  has_many :user_links, :dependent => :destroy
  has_many :suite_executions, :dependent => :destroy
  has_many :user_functions
  has_many :task_programs, :dependent => :destroy
  has_many :assignments

  acts_as_authorized_user
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  alias :unsafe_has_role :has_role
  alias :unsafe_has_no_role :has_no_role

  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :name,:language,:email, :password, :password_confirmation, :active,:api_key #, :remember_token_expires_at, :remember_token


  validates_presence_of     :login, :email, :name,              :message => _("User, Name and E-Mail are Mandatory Fields ")
  validates_presence_of     :password,                   :if => :password_required?, :message => _("Must enter a Password")
  validates_presence_of     :password_confirmation,      :if => :password_required?, :message => _("Must enter Password Confirmation")
  validates_length_of       :password, :within => 4..40, :if => :password_required?, :message => _("Password must contain between 4 and 40 caracters")
  validates_confirmation_of :password,                   :if => :password_required?, :message => _("Password Confirmation is Wrong")
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..50
  validates_uniqueness_of   :login, :email, :case_sensitive => false, :message => _("Existing User")
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => _("Invalid Mail format")
  validate                  :manager_cannot_be_deactivated

  after_save     :notify_project_managers_if_user_becomes_inactive
  before_save    :encrypt_password
  after_save     :expires_cached_user
  before_destroy :expires_cached_user, :expires_cached_user_circuits_edit
  after_create   :user_stuff, :send_mail,:enable_api!

  class AccessDenied < Exception
    def initialize( str )
      @str = str
    end

    def to_s
      @str
    end
  end

  def <=> other
    self.login.downcase <=> other.login.downcase
  end

  def user_stuff
    self.user_configuration=UserConfiguration.create(
      :debug_mode => CaciqueConf::DEBUG_MODE,
      :remote_control_addr => CaciqueConf::REMOTE_CONTROL_ADDR,
      :remote_control_port => CaciqueConf::REMOTE_CONTROL_PORT,
      :remote_control_mode => CaciqueConf::REMOTE_CONTROL_MODE
    )

    self.user_configuration.add_first_user_configuration_values

    #Note CACIQUE
    self.notes.create

    #Links
    self.user_links.create(:name => "Cacique",:link => 'http://cacique.mercadolibre.com/')
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    remember_token_expires_at = nil
    remember_token            = nil
    save(false)
  end

  # Returns true if the user has just been activated. (restful_authentication)
  def recently_activated?
    @activated
  end

  # Returns true if the user has became deactivated. (user.active)
  def recently_deactivated?
    self.active_changed? and !self.active
  end

  def has_role( role_name, obj = nil, option = nil )
    # to allocate roles, the current user must have "security" permissions
    check_security_permissions(obj) unless option == :nocheck
    super(role_name, obj)
  end

  def has_no_role( role_name, obj = nil, option = nil )
    # to allocate roles, the current user must have "security" permissions
    check_security_permissions(obj) unless option == :nocheck
    super(role_name, obj)
  end

  def check_security_permissions(obj)

    if current_user then
      return true if current_user.has_role?("root")
    end

    if obj then
      if current_user then
        unless current_user.has_role?("security", obj)
          raise AccessDenied.new("Access denied to #{self.inspect}")
        end
      end
    else
      # to allocate roles to users, the current user must have "administrator" permissions
      if current_user then
        unless current_user.has_role?("root")
          raise AccessDenied.new("Access denied to #{self.inspect}")
        end
      end
    end
  end


  def has_role? ( role_name, obj = nil)
    #admin user have total acces
    if role_name != "root" then

      #root user have any rol
      return true if self.has_role?("root")
    end

    if role_name == "viewer" or role_name == "enumerator_of_suites" then
      #any user have "viewer" rol
      return true
    end

    if role_name == "creator_of_case_templates" then
      if obj.instance_of? Circuit
        if obj.category
          proj = obj.category.indirect_project
          if proj
            if has_role?("editor", proj) then
              return true
            end
          end
        end
      end
    end


    if obj.instance_of? Suite
      proj = obj.project
      if proj
        return super(role_name, obj ) || super( role_name + " of suites", proj ) || super(role_name, proj)
      end
    end

    if obj.instance_of? Category
      proj = obj.indirect_project
      if proj
        return super(role_name, obj ) || super( role_name + " of categories", proj )  || super(role_name, proj)
      end
    end

    if obj.instance_of? CaseTemplate
      if obj.circuit
        if obj.circuit.category
          proj = obj.circuit.category.indirect_project
          if proj
            return super(role_name, obj ) || super( role_name + " of case_templates", proj ) || super(role_name, proj)
          end
        end
      end
    end

    if obj.instance_of? Circuit
      if obj.category
        proj = obj.category.indirect_project
        if proj
          return super(role_name, obj ) || super( role_name + " of circuits", proj ) || super(role_name, proj)
        end
      end
    end

    if obj.instance_of? Project
      if role_name == "creator_of_suites" then
        return true if super("editor", obj)
      end
    end

    super(role_name, obj )
  end

  def has_no_role? ( role_name, obj = nil)
    not has_role?(role_name,obj)
  end


  #user password recovery
  def email_password_recovery(server_port)
    Notifier.deliver_password_recovery(self, server_port)
  end

  def active?
    self.active
  end

  def manager?
    Project.count(:conditions => {:user_id => self.id}) > 0
  end

  def managed_projects
    Project.find(:all, :conditions => {:user_id => self.id})
  end

  def manager_cannot_be_deactivated
    if !active? and manager?
      self.active = true
      projects = managed_projects.collect(&:name).join(', ')
      errors.add(:active, "can't be unset for project managers (#{projects})")
    end
  end

  #user password change
  def email_password_changed
    Notifier.deliver_password_changed(self)
  end

  def self.deactivate(login)
    u= User.find_by_login(login)
    unless u.nil?
      u.active=false
      u.save
    end
  end

  def self.activate(login)
    u= User.find_by_login(login)
    unless u.nil?
      u.active=true
      u.save
    end
  end

  #is FALSE when user was deleted
  def self.active?(login)
    u=User.find_by_login(login)
    return true if u==nil #must be true if user not exist
    return u.active
  end

  # Return: { user => [project, project, ...],
  #           user => [project, project, ...] }
  def projects_by_manager
    hash = Hash.new([])
    projects.each do |project|
      if hash.has_key? project.user
        hash[project.user] << project
      else
        hash[project.user] = [project]
      end
    end
    hash
  end

  def task_by_projects projects
    TaskProgram.sumarize_by_user_and_projects self, projects
  end

  def notify_project_managers_if_user_becomes_inactive
    return unless recently_deactivated?

    projects_by_manager.each_pair do |manager, projects|
      tasks = task_by_projects projects
      Notifier.deliver_user_inactive(manager, self, tasks)
    end
    task_programs.each do |task|
      task.destroy
    end
  end

  def expires_cached_user
    Rails.cache.delete "user_#{self.id}"
  end

  def expires_cached_user_circuits_edit
    Rails.cache.delete("circuit_edit_#{self.id}")
  end

  #return the projects asigned to user
  def my_projects
    user_projects=Array.new
    values= Rails.cache.fetch("user_projects_#{self.id}"){ self.projects.map(&:id) }

    values.each do |prj|
      user_projects << Project.find(prj.to_i)
    end
    user_projects.sort{|x,y| x.name <=> y.name}.sort_by { |x| x.name.downcase }
  end

  #Returns true if the user has permissions to manage the project.
  def has_permission_admin_project?(project_id)
    return true if self.has_role?("root")

    project_ids = Rails.cache.fetch("user_projects_#{self.id}"){ self.projects.map(&:id) }
    return project_ids.include?(project_id.to_i)
  end

  # load user projects in cache, asigned or unassigned to him
  # and return unassigned projects
  # create an vector with ALL ids
  def other_projects
    other_prj=[]
    all_ids= Rails.cache.fetch("projects_ids"){Project.all.map(&:id)}
    #calculate id for the other projects
    #if user id is not cached,  does here
    other_ids= all_ids - self.my_projects.map(&:id)

    other_ids.each do |identifier|
      other_prj << Project.find(identifier.to_i)
    end
    other_prj.sort{|x,y| x.name <=> y.name}.sort_by { |x| x.name.downcase }
  end

  #user projects refresh
  #vector id refresh
  def reload_cached_projects
    Rails.cache.write("projects_ids" , Project.all.map(&:id))
    Rails.cache.delete("user_projects_#{self.id}")
  end

  def enable_api!
    self.generate_api_key!
  end

  def disable_api!
    #should be ....
    #self.update_attribute(:api_key, "")

    usr=User.find_by_login(current_user.login)
    usr.update_attribute(:api_key, "")
    expires_cached_user
    current_user=usr
  end

  def api_is_enabled?
    !self.api_key.empty?
  end


  protected
    # before filter
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end

    def password_required?
      crypted_password.blank? || !password.blank? || !password_confirmation.blank?
    end


  def send_mail
    begin
      Notifier.deliver_signup_mail(self)
    rescue
      #You should confing your mailserver to send mail when creating accounts.
    end
  end

  def secure_digest(*args)
    Digest::SHA1.hexdigest(args.flatten.join('--'))
  end

  def generate_api_key!
    # Note: This is a dirty code, it should be something like:
    #       self.update_attribute(:api_key, secure_digest(Time.now, (1..10).map{ rand.to_s }))
    #       But Rails 2.3.x has a bug, and all Activerecord objects cached on memcached are frozen
    #       and I couldn't modify, currently It's tested on rails 2.3.5 and 2.3.9 and It's not fixed yet
    #       for more info about this bug: http://sleeplesscoding.blogspot.com/2010/08/rails-23-activesupportcachememorystore.html
    usr=User.find_by_login(self.login)
    usr.update_attribute(:api_key, secure_digest(Time.now, (1..10).map{ rand.to_s }))
    expires_cached_user
    current_user=usr
  end


  def self.find(*args)
    if args.first.instance_of?(Fixnum) and args.length == 1
      Rails.cache.fetch "user_#{args.first}" do
        super(*args)
      end
    else
      super(*args)
    end
  end

end
