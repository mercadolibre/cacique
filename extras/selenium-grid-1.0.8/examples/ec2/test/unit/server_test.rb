require File.dirname(__FILE__) + "/test_helper"

unit_tests do

  test "refresh_status updates public dns" do
    server = SeleniumGrid::AWS::Server.new :an_instance_id
    SeleniumGrid::AWS::Server.expects(:describe).with(:an_instance_id).
                              returns(:public_dns => :new_public_dns)
    server.refresh_status
    assert_equal :new_public_dns, server.public_dns
  end

  test "refresh_status updates private dns" do
    server = SeleniumGrid::AWS::Server.new :an_instance_id
    SeleniumGrid::AWS::Server.expects(:describe).with(:an_instance_id).
                              returns(:private_dns => :new_private_dns)
    server.refresh_status
    assert_equal :new_private_dns, server.private_dns
  end

  
end