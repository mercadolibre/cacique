class AddColumnEmailsToSendOkAndFailInUserConfiguration < ActiveRecord::Migration

  def self.up
         rename_column :user_configurations, :send_mail, :send_mail_ok
	 add_column :user_configurations, :send_mail_fail, :boolean, :default => true  
  end

  def self.down
         rename_column :user_configurations, :send_mail_ok, :send_mail
	 remove_column :user_configurations, :send_mail_fail
  end

end
