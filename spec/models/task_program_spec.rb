require 'spec_helper'

describe TaskProgram do
  before(:each) do
     suite         = mock(:suite)
     @task_program = Factory(:task_program, :suite_id=>suite.id)
  end

  it "should create a new instance given valid attributes" do
      @task_program.save.should be_true
  end


end
