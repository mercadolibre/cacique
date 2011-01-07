require File.dirname(__FILE__) + "/test_helper"

unit_tests do

  test "ssh_command builds ssh based command targetting the host" do
    command = SeleniumGrid::AWS::RemoteCommand.new "ls", :host => "the.host"
    assert_equal "ssh root@the.host", command.ssh_command
  end

  test "ssh_command use custom key when keypair options is provided" do
    command = SeleniumGrid::AWS::RemoteCommand.new "ls", 
                :host => "the.host", :keypair => "/the/key.pair"
    assert_equal "ssh -i '/the/key.pair' root@the.host", command.ssh_command
  end

  test "remote_command" do
    command = SeleniumGrid::AWS::RemoteCommand.new "ls", :pwd => "/a/directory"
    assert_equal "cd '/a/directory'; ls", command.remote_command
  end

  test "remote_command set path when path is provided as an option" do
    command = SeleniumGrid::AWS::RemoteCommand.new "ls", :path => "/a/directory:and/another"
    assert_equal "PATH=/a/directory:and/another:${PATH}; export PATH; ls", command.remote_command
  end

  test "remote_command set display when display is provided as an option" do
    command = SeleniumGrid::AWS::RemoteCommand.new "ls", :display => ":0"
    assert_equal "DISPLAY=:0; export DISPLAY; ls", command.remote_command
  end

  test "full_command execute the remote command using ssh_command" do
    command = SeleniumGrid::AWS::RemoteCommand.new nil
    command.stubs(:ssh_command).returns("the_ssh_command")
    command.stubs(:remote_command).returns("the remote command")
    assert_equal "the_ssh_command 'the remote command'", command.full_command
  end

  test "full_command wraps remote_command with 'su user -c' when su option is set" do
    command = SeleniumGrid::AWS::RemoteCommand.new nil, :su => "a-user"
    command.stubs(:ssh_command).returns("the_ssh_command")
    command.stubs(:remote_command).returns("the remote command")
    assert_equal "the_ssh_command \"su -l a-user -c 'the remote command'\"", 
                 command.full_command
  end
  
end