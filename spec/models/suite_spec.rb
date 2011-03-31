require 'spec_helper'
require 'factory_girl'
Factory.find_definitions

describe Suite do
  before(:each) do
     project = Factory(:project)
     @suite =  Factory(:suite, :project=> project)
  end

  it "should create a new instance given valid attributes" do
       @suite.save.should be_true
  end
end
