require 'spec_helper'
require 'pry'

describe Connfuse do
  it 'has a version number' do
    expect(Connfuse::VERSION).not_to be nil
  end

  class TestClass
    class TestError < StandardError; end
    include Connfuse

    def test(to_fail = nil)
      raise TestError if to_fail
      'result'
    end

    fuse_for :test
  end
end
