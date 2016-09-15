require 'spec_helper'

describe Connfuse do
  it 'has a version number' do
    expect(Connfuse::VERSION).not_to be nil
  end

  context 'fuse_for wrapping methods via pass_thru' do
    class TestClass
      class TestError < StandardError; end
      include Connfuse

      def test(to_fail = nil)
        raise TestError if to_fail
        'result'
      end

      fuse_for :test
    end

    # TODO: write tests
  end
end
