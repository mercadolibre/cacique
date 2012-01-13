class FixingIpHubOnWebdriverInit < ActiveRecord::Migration
  def self.up
	if fn=UserFunction.find_by_name("webdriver_init")
		fn.source_code=fn.source_code.gsub("10.4.255.99:5555","#{WEBDRIVER_HUB_IP}:#{WEBDRIVER_HUB_PORT}")
		fn.save
        end
  end

  def self.down
  end
end
