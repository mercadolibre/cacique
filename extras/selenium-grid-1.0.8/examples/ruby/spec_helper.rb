$:.unshift

require "rubygems"
gem "rspec", "=1.1.8"
require 'spec/rake/spectask'

require "rake"

gem "selenium-client", "=1.2.7"
require "selenium/rake/tasks"
require "selenium/client"
require "selenium/rspec/spec_helper"

require File.expand_path(File.dirname(__FILE__) + "/google_image_example")

Spec::Runner.configure do |config|

  config.before(:each) do
    create_selenium_driver
    start_new_browser_session
  end

  # The system capture need to happen BEFORE the closing the Selenium session 
  config.append_after(:each) do    
    @selenium_driver.close_current_browser_session
  end

  def start_new_browser_session
    @selenium_driver.start_new_browser_session
    @selenium_driver.set_context "Starting example '#{self.description}'"
  end

  def selenium_driver
    @selenium_driver
  end

  def browser
    @selenium_driver
  end

  def page
    @selenium_driver
  end

  def create_selenium_driver
    remote_control_server = ENV['SELENIUM_RC_HOST'] || "localhost"
    port = ENV['SELENIUM_RC_PORT'] || 4444
    browser = ENV['SELENIUM_RC_BROWSER'] || "*firefox"
    timeout = ENV['SELENIUM_RC_TIMEOUT'] || 200
    application_host = ENV['SELENIUM_APPLICATION_HOST'] || "images.google.com"
    application_port = ENV['SELENIUM_APPLICATION_PORT'] || "80"

    @selenium_driver = Selenium::Client::Driver.new(
        remote_control_server, port, browser,
        "http://#{application_host}:#{application_port}", timeout)
  end

end

