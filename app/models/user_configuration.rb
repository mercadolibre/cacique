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
# == Schema Information
# Schema version: 20101129203650
#
# Table name: user_configurations
#
#  id                  :integer(4)      not null, primary key
#  user_id             :integer(4)
#  send_mail           :boolean(1)
#  debug_mode          :boolean(1)
#  remote_control_mode :string(255)
#  remote_control_addr :string(255)
#  remote_control_port :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#

class UserConfiguration < ActiveRecord::Base
  belongs_to :user
  has_many :user_configuration_values, :dependent => :destroy

  validates_presence_of :user_id, :message => _("Must complete circuit_id")

  attr_accessor :emails_to_send_ok
  attr_accessor :emails_to_send_fail

  # user_configuration_values generator for all run configuration with value=nil
    def add_first_user_configuration_values
    context_configurations = ContextConfiguration.all
    context_configurations.each do |context_configuration|
      add_user_configuration_value(context_configuration.id, "") 
    end
  end
  
  #add new user_configuration_value
  def add_user_configuration_value(context_configuration_id, value)
    user_configuration_value = self.user_configuration_values.new
    user_configuration_value.context_configuration_id = context_configuration_id
    user_configuration_value.value = value
    user_configuration_value.save
  end

  #context_configurations hash generator // {:name => valor}
  def get_hash_values
    values = {}
    self.user_configuration_values.each do |user_configuration_value|
      values[user_configuration_value.context_configuration.name] = user_configuration_value.value
    end
    
    values
  end
  

  #user_configuration_values update
  def update_configuration(values)
    if values.has_key?(:send_mail_ok) 
      self.send_mail_ok = true
      if values.has_key?(:emails_to_send_ok)
        if values[:emails_to_send_ok].instance_of? Array
          @emails_to_send_ok = values[:emails_to_send_ok].join(",")
        else
          @emails_to_send_ok = values[:emails_to_send_ok].gsub(";",",")  
        end
      else
        @emails_to_send_ok = current_user.email
      end
    else
      self.send_mail_ok = false
      @emails_to_send_ok = []
    end
 
    if values.has_key?(:send_mail_fail) 
      self.send_mail_fail = true
      if values.has_key?(:emails_to_send_fail)
        if values[:emails_to_send_fail].instance_of? Array
          @emails_to_send_fail = values[:emails_to_send_fail].join(",")
        else
          @emails_to_send_fail = values[:emails_to_send_fail].gsub(";",",")  
        end
      else
        @emails_to_send_fail = current_user.email
      end
    else
      self.send_mail_fail = false
      @emails_to_send_fail = []
    end
   
    self.debug_mode = values.has_key?(:debug_mode) 
    self.remote_control_addr = values[:remote_control_addr]
    self.remote_control_port = values[:remote_control_port]
    self.remote_control_mode = values[:remote_control_mode]
    self.save  
    change_user_configuration_values(values)
  end
  
  
  def change_user_configuration_values(values)
    self.user_configuration_values.each do |user_configuration_value|
      context_configuration_name = user_configuration_value.context_configuration.name
      if values[context_configuration_name].class == Array
        #_ Are removed because if it is a scheduled run _ are added not to pull the command error
        value = values[context_configuration_name].join(";").gsub("_", " ")
      elsif values.has_key?(context_configuration_name)
        #_ Are removed because if it is a scheduled run _ are added not to pull the command error
        value = values[context_configuration_name].gsub("_"," ")
      else
        value = ""
      end
      user_configuration_value.value = value
      user_configuration_value.save
    end
  end
  
  #search the number of combinations that I can do with run configuration
  #[{:site => "ar"},{:site => "br"}]
  def run_combinations
    all_combinations = []
    
    text_for_the_variable = "all_combinations << {"
    text_for_the_rest = ""
    cant_ends = 0
    c = 0 # A NUMBER for no repeat conf_value name in every each
    self.user_configuration_values.each do |user_configuration_value|
      if user_configuration_value.value.empty?
        text_for_the_rest = "1.times do \n conf_value#{c} = \"\"\n" + text_for_the_rest
      else
        text_for_the_rest = "\"#{user_configuration_value.value}\".split(';').each do |conf_value#{c}|\n" + text_for_the_rest
      end
      
      text_for_the_variable += "\"#{user_configuration_value.context_configuration.name}\" => conf_value#{c},"
    
      cant_ends += 1
      c += 1
    end
    
    #delete "," if exist and close hash

    if text_for_the_variable[-1] == ","
      text_for_the_variable[-1] = "}"
    else
      text_for_the_variable += "}"
    end
    
    text_to_run = text_for_the_rest + text_for_the_variable
    
    #add needed "end"
    cant_ends.times do
      text_to_run += "\nend\n"
    end

    eval(text_to_run)
    
    all_combinations
  end
  
end
