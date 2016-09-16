require 'spec_helper'

describe Connfuse do
  it 'has a version number' do
    expect(Connfuse::VERSION).not_to be nil
  end

  describe '#fuse_for' do
    class TestClass
      class TestError < StandardError; end
      include Connfuse

      def test(to_fail = nil)
        raise TestError if to_fail
        'result'
      end

      fuse_for :test
    end

    subject { TestClass.new }

    it 'wrapping methods via pass_thru' do
      expect(TestClass.circuit.failure_count).to eq 0
      expect(subject.test).to eq 'result'
      expect { subject.test(true) }.to raise_error TestClass::TestError
      expect(TestClass.circuit.failure_count).to eq 1
    end
  end
end
