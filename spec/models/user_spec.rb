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

require 'spec_helper'

describe User do
  before(:each) do
     @user = Factory(:user)
  end

  #it "should create a new instance given valid attributes" do
  #  @user.save.should 0
  #end
  it "Users should be created as inactive" do

    @user=User.create(:login=>"testing1",:name=>"test",:email=>"testing@test.com",:password=>"test",:password_confirmation=>"test")
    @user.active?.should == false
  end
end
