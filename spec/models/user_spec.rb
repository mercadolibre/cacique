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
