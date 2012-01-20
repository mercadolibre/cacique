# == Schema Information
# Schema version: 20110630143837
#
# Table name: projects
#
#  id          :integer(4)      not null, primary key
#  name        :string(255)
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  user_id     :integer(4)
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
class Project < ActiveRecord::Base

  has_many :suites, :dependent => :destroy

  has_many :categories,      :dependent => :destroy
  has_many :project_users,   :dependent => :destroy
  has_many :suite_executions,:dependent => :destroy
  has_many :user_functions,  :dependent => :destroy
  has_many :task_programs,   :dependent => :destroy
  belongs_to :user
  has_many :circuits #should be destroy on categories destroy

  validates_presence_of	:name, :message=> _("Enter Project Name")
  validates_presence_of :description, :message=> _("Enter Project Description")
  validates_presence_of :user_id, :message => _("Enter a Project Manager")
  validates_uniqueness_of  :name, :case_sensitive => false, :message => _("The project already exists!")

  acts_as_authorizable
  has_many :users, :through => :project_users
  after_save :expires_project_cache
  
  #assing user to project
  def assign(user_id)
    user = User.find user_id
    if self.users.include?(user)
      self.errors.add(:relation, _('User is already assigned to the project'))
      return false
    end
    unless user.active?
      self.errors.add(:relation, _('User is inactive'))
      return false
    end
    ProjectUser.create(:user_id=>user_id, :project_id=>self.id)
    user.reload_cached_projects
  end
  
  #Assing manager for the proyect
  def assign_manager(user_id)
    user = User.find user_id   
    return unless user.active?
    self.assign(user_id) if !self.users.include?(user) #if user is not assig
    self.user_id = user.id
    user.reload_cached_projects
    self.save
  end
  
  #create user project relation
  def creater_user_relation(user_id)
    #create user relation if not exist
    relation = ProjectUser.find(:first,:conditions => ["project_id = ? and user_id = ?", self.id, user_id]) 
    self.assign(user_id) if relation.nil?
  end
 
  #delete user project relation
  def deallocate(user_id)
       user = User.find user_id
       if !self.users.include?(user)
         self.errors.add(:relation, _('Relation that try delete do not exists'))
         return false
       end
       #for a project responsible
       if self.user.id == user_id.to_i
         self.errors.add(:responsable, _('Unable to deallocate Project Manager'))
         return false
       end
       project_user = self.project_users.find_by_user_id user.id
       user.reload_cached_projects
       project_user.destroy
  end
  
  #add all relation categories to memcached ( Project->categories )
  def all_cached_categories
    Rails.cache.fetch("project_categories_#{self.id}")  { self.categories }
  end

  def search_circuit(name_)
    circuits = Array.new
    Circuit.find(:all).each do |circuit|
      if circuit.category then
        proj = circuit.category.indirect_project

        if proj then
          if proj.id == self.id then
            if circuit.name == name_ then
              circuits << circuit
            end
          end
        end
      end
    end

    if circuits.size > 1 then
      raise _("Search by Script name is ambiguous")
    end

    if circuits.size == 1 then
      return circuits.first
    end
    nil
  end

  def expires_project_cache
    Rails.cache.delete "project_#{id}"
  end


  #def circuits
  #  return category_circuits(self.categories)
  #end

   def category_circuits(categories)
      circuits = Array.new
      unless categories.empty?
        categories.each do |category|
           #Tiene padre
           if category.parent
                #Scripts
                 category.circuits.each do |circuit|
                   circuits << circuit
                 end
           else
              #Categoria principal
              #Scripts
               category.circuits.each do |circuit|
                   circuits << circuit
               end
           end
           childrens = category.children
           circuits += category_circuits(childrens)
        end
      end
      circuits
   end




  #cachea cada project cuando se hace un find y luego se expira dicha cache en before_save 
  def self.find(*args)
    if args.first.instance_of?(Fixnum) and args.length == 1
      Rails.cache.fetch "project_#{args.first}" do
        super(*args)
      end
     
    else
      super(*args)
    end
  end

  #get project suite id
  def suites_cache
     return Rails.cache.fetch("project_suites_#{self.id}", :expires_in => CACHE_EXPIRE_PROYECT_SUITES) { self.suites.active.map(&:id) }
  end


end
