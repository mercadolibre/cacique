require File.dirname(__FILE__) + "/test_helper"

unit_tests do

  test "run_instance launch a new AMI using ec2-run-instances script" do
    client = Class.new.extend SeleniumGrid::AWS::Ec2Client
    client.expects(:ec2_shell).with("ec2-run-instances TheAMI -k TheKeyPair")
    client.launch "TheAMI", :keypair => "TheKeyPair"
  end

  test "run_instance returns the instance id when launch is successful" do
    client = Class.new.extend SeleniumGrid::AWS::Ec2Client
    client.stubs(:ec2_shell).returns(<<-EOS)
      RESERVATION	r-ee629587	069216575636	default
      INSTANCE	i-6fef1006	ami-d306e3ba			pending	grid-keypair	0		m1.small	2008-02-17T20:49:08+0000
    EOS
    assert_equal "i-6fef1006", client.launch(:an_ami)
  end

  test "authorize launch ec2-authorize script for default group" do
    client = Class.new.extend SeleniumGrid::AWS::Ec2Client
    client.expects(:ec2_shell).with("ec2-authorize default -p ThePort")
    client.authorize_port "ThePort"
  end

  test "describe launch ec2-describe script for a particular AMI" do
    client = Class.new.extend SeleniumGrid::AWS::Ec2Client
    client.expects(:ec2_shell).with("ec2-describe-instances TheAMI").returns("INSTANCE i-")
    client.describe "TheAMI"
  end

  test "describe returns the instance id when running" do
    client = Class.new.extend SeleniumGrid::AWS::Ec2Client
    client.stubs(:ec2_shell).returns(<<-EOS)
      RESERVATION	r-ee629587	069216575636	default
      INSTANCE	i-6fef1006	ami-d306e3ba	ec2-67-202-19-143.compute-1.amazonaws.com	domU-12-31-38-00-3D-E6.compute-1.internal	running	grid-keypair	0		m1.small	2008-02-17T20:49:08+0000      
    EOS
    assert_equal "i-6fef1006", client.describe(:an_ami)[:instance_id]
  end

  test "describe returns the ami when running" do
    client = Class.new.extend SeleniumGrid::AWS::Ec2Client
    client.stubs(:ec2_shell).returns(<<-EOS)
      RESERVATION	r-ee629587	069216575636	default
      INSTANCE	i-6fef1006	ami-d306e3ba	ec2-67-202-19-143.compute-1.amazonaws.com	domU-12-31-38-00-3D-E6.compute-1.internal	running	grid-keypair	0		m1.small	2008-02-17T20:49:08+0000      
    EOS
    assert_equal "ami-d306e3ba", client.describe(:an_ami)[:ami]
  end

  test "describe returns the public_dns when running" do
    client = Class.new.extend SeleniumGrid::AWS::Ec2Client
    client.stubs(:ec2_shell).returns(<<-EOS)
      RESERVATION	r-ee629587	069216575636	default
      INSTANCE	i-6fef1006	ami-d306e3ba	ec2-67-202-19-143.compute-1.amazonaws.com	domU-12-31-38-00-3D-E6.compute-1.internal	running	grid-keypair	0		m1.small	2008-02-17T20:49:08+0000      
    EOS
    assert_equal "ec2-67-202-19-143.compute-1.amazonaws.com", 
                 client.describe(:an_ami)[:public_dns]
  end

  test "describe returns the private_dns when running" do
    client = Class.new.extend SeleniumGrid::AWS::Ec2Client
    client.stubs(:ec2_shell).returns(<<-EOS)
      RESERVATION	r-ee629587	069216575636	default
      INSTANCE	i-6fef1006	ami-d306e3ba	ec2-67-202-19-143.compute-1.amazonaws.com	domU-12-31-38-00-3D-E6.compute-1.internal	running	grid-keypair	0		m1.small	2008-02-17T20:49:08+0000      
    EOS
    assert_equal "domU-12-31-38-00-3D-E6.compute-1.internal", 
                 client.describe(:an_ami)[:private_dns]
  end

  test "describe returns the status when running" do
    client = Class.new.extend SeleniumGrid::AWS::Ec2Client
    client.stubs(:ec2_shell).returns(<<-EOS)
      RESERVATION	r-ee629587	069216575636	default
      INSTANCE	i-6fef1006	ami-d306e3ba	ec2-67-202-19-143.compute-1.amazonaws.com	domU-12-31-38-00-3D-E6.compute-1.internal	running	grid-keypair	0		m1.small	2008-02-17T20:49:08+0000      
    EOS
    assert_equal "running", client.describe(:an_ami)[:status]
  end

  test "describe returns the instance id when terminated" do
    client = Class.new.extend SeleniumGrid::AWS::Ec2Client
    client.stubs(:ec2_shell).returns(<<-EOS)
      RESERVATION	r-ee629587	069216575636	default
      INSTANCE	i-6fef1006	ami-d306e3ba			terminated	grid-keypair	0		m1.small	2008-02-17T20:49:08+0000
    EOS
    assert_equal "i-6fef1006", client.describe(:an_ami)[:instance_id]
  end

  test "describe returns the status when pending" do
    client = Class.new.extend SeleniumGrid::AWS::Ec2Client
    client.stubs(:ec2_shell).returns(<<-EOS)
      RESERVATION	r-40609729	069216575636	default
      INSTANCE	i-afee11c6	ami-6801e401			pending	grid-keypair	0		m1.small	2008-02-17T22:33:38+0000
    EOS
    assert_equal "pending", client.describe(:an_ami)[:status]
  end

  test "describe returns a nil public dns the status when pending" do
    client = Class.new.extend SeleniumGrid::AWS::Ec2Client
    client.stubs(:ec2_shell).returns(<<-EOS)
      RESERVATION	r-40609729	069216575636	default
      INSTANCE	i-afee11c6	ami-6801e401			pending	grid-keypair	0		m1.small	2008-02-17T22:33:38+0000
    EOS
    assert_nil client.describe(:an_ami)[:public_dns]
  end

  test "describe returns a nil private dns the status when pending" do
    client = Class.new.extend SeleniumGrid::AWS::Ec2Client
    client.stubs(:ec2_shell).returns(<<-EOS)
      RESERVATION	r-40609729	069216575636	default
      INSTANCE	i-afee11c6	ami-6801e401			pending	grid-keypair	0		m1.small	2008-02-17T22:33:38+0000
    EOS
    assert_nil client.describe(:an_ami)[:private_dns]
  end

  test "describe returns the status when terminated" do
    client = Class.new.extend SeleniumGrid::AWS::Ec2Client
    client.stubs(:ec2_shell).returns(<<-EOS)
      RESERVATION	r-ee629587	069216575636	default
      INSTANCE	i-6fef1006	ami-d306e3ba			terminated	grid-keypair	0		m1.small	2008-02-17T20:49:08+0000
    EOS
    assert_equal "terminated", client.describe(:an_ami)[:status]
  end

  test "shutdown terminates an instance" do
    client = Class.new.extend SeleniumGrid::AWS::Ec2Client
    client.expects(:ec2_shell).with("ec2-terminate-instances The-Instance-ID")
    client.shutdown("The-Instance-ID")
  end

  test "version returns EC2 version using defined keypair" do
    client = Class.new.extend SeleniumGrid::AWS::Ec2Client
    client.expects(:ec2_shell).with("ec2-version").returns(:ec2_version)
    assert_equal :ec2_version, client.version
  end

# ec2-version -K "${EC2_PRIVATE_KEY}"
end