#!/usr/bin/env ruby
Dir['**/*_test.rb'].each {|test_file| require test_file }