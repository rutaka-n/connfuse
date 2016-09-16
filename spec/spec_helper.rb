require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'connfuse'
require 'connfuse/circuit'
require 'webmock/rspec'
require 'timecop'
require 'pry'
WebMock.disable_net_connect!(allow: %r{https://codeclimate.com/test_reports})
