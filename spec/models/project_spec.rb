require 'spec_helper'

describe Project do
  before(:each) do
     @project = Factory(:project)
  end

  it "should create a new instance given valid attributes" do
      @project.save.should be_true
  end

end
