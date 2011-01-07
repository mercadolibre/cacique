require File.dirname(__FILE__) + "/test_helper"

unit_tests do

  test "hub is nil on a fresh cloud" do
    assert_nil SeleniumGrid::AWS::Cloud.new.hub
  end

  test "hub return the latest assigned hub instance" do
    cloud = SeleniumGrid::AWS::Cloud.new
    cloud.hub = :old_hub
    cloud.hub = :new_hub
    assert_equal :new_hub, cloud.hub
  end

  test "remote_control_farms is empty on a fresh cloud" do
    assert_equal [], SeleniumGrid::AWS::Cloud.new.farms
  end

  test "remote_control_farms returns all added farms" do
    cloud = SeleniumGrid::AWS::Cloud.new
    cloud.farms << :a_farm
    cloud.farms << :another_farm
    assert_equal [:a_farm, :another_farm], cloud.farms
  end

end