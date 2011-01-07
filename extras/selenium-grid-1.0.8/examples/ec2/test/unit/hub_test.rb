require File.dirname(__FILE__) + "/test_helper"

unit_tests do

  test "url return the public url where the hub can be contacted" do
    hub = SeleniumGrid::AWS::Hub.new nil
    hub.public_dns = "public.dns"
    assert_equal "http://public.dns:4444", hub.url
  end

  test "private_url return the private url where the hub can be contacted" do
    hub = SeleniumGrid::AWS::Hub.new nil
    hub.private_dns = "private.dns"
    assert_equal "http://private.dns:4444", hub.private_url
  end

  test "console_url return the public url of the hub console" do
    hub = SeleniumGrid::AWS::Hub.new nil
    hub.public_dns = "public.dns"
    assert_equal "http://public.dns:4444/console", hub.console_url
  end


end