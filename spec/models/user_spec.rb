require 'spec_helper'

describe User do
  before(:each) do
     @user = Factory(:user)
  end

  it "should create a new instance given valid attributes" do
    @user.save.should be_true
  end
end
