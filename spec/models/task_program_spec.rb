require 'spec_helper'

describe TaskProgram do
  before(:each) do
     suite         = mock(:suite)
     @task_program = Factory(:task_program, :suite_id=>suite.id)
  end

  it "should create a new instance given valid attributes" do
      @task_program.save.should be_true
  end

  it "should generate two dates, one at 10 pm. and another to 12pm. " do
      params = HashWithIndifferentAccess.new({"range_repeat"=>"each", "init_hour"=>"10:00", "runs"=>"3", "frecuency"=>"daily", "per_each"=>"1", "range"=>"today", "one_date"=>"08.04.2011", "init_date"=>"07.04.2011", "finish_date"=>"07.04.2011", "each_hour_or_min"=>"hours"})
      date = Time.local('2011', '04', '07', '10', '00', '00')
      #Response
      date1 = Time.local('2011', '04', '07', '10', '00', '00')
      date2 = Time.local('2011', '04', '07', '11', '00', '00')
      date3 = Time.local('2011', '04', '07', '12', '00', '00')
      TaskProgram.program_repeat(params, date).should == [date1, date2, date3]
  end

  it "should generate two dates, one at 10 pm. and another to 10:30pm. " do
      params = HashWithIndifferentAccess.new({"range_repeat"=>"each", "init_hour"=>"10:00", "runs"=>"3", "frecuency"=>"daily", "per_each"=>"15", "range"=>"today", "one_date"=>"08.04.2011", "init_date"=>"07.04.2011", "finish_date"=>"07.04.2011", "each_hour_or_min"=>"min"})
      date = Time.local('2011', '04', '07', '10', '00', '00')
      #Response
      date1 = Time.local('2011', '04', '07', '10', '00', '00')
      date2 = Time.local('2011', '04', '07', '10', '15', '00')
      date3 = Time.local('2011', '04', '07', '10', '30', '00')
      TaskProgram.program_repeat(params, date).should == [date1, date2, date3]
  end

end
