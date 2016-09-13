require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'connfuse'
require 'webmock/rspec'
WebMock.disable_net_connect!(allow: %r{https://codeclimate.com/test_reports})
