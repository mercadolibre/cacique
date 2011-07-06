# == Schema Information
# Schema version: 20110630143837
#
# Table name: suites
#
#  id          :integer(4)      not null, primary key
#  name        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  description :text
#  project_id  :integer(4)
#

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
