require 'spec_helper'

describe Connfuse::Circuit do
  class ExpectedError < RuntimeError; end
  subject(:circuit) { described_class.new(expected_errors: [ExpectedError]) }

  describe '#break!' do
    it 'change status to :broken' do
      expect { circuit.break! }.to change { circuit.status }.to(:broken)
    end
  end

  describe '#load!' do
    it 'change status to :loaded' do
      circuit.break!
      expect { circuit.load! }.to change { circuit.status }.to(:loaded)
    end

    it 'unset failure_count' do
      circuit.register_failure(StandardError)
      expect { circuit.load! }.to change { circuit.failure_count }.to(0)
    end
  end

  describe '#loaded?' do
    it { expect(circuit.loaded?).to be true }

    it do
      circuit.break!
      expect(circuit.loaded?).to be false
    end
  end

  describe '#broken?' do
    it { expect(circuit.broken?).to be false }

    it do
      circuit.break!
      expect(circuit.broken?).to be true
    end
  end

  describe '#register_failure' do
    it 'increment failure_count and save error info' do
      Timecop.freeze(Time.now) do
        expect { circuit.register_failure(StandardError) }.to change { circuit.failure_count }.by(1)
        expect(circuit.last_error).to be StandardError
        expect(circuit.last_failed_at).to eq Time.now
      end
    end

    it 'do not register expected_errors' do
      expect { circuit.register_failure(ExpectedError) }.not_to change { circuit.failure_count }
    end
  end

  describe '#pass_thru' do
    let(:method) do
      ->(to_fail = false) do
        raise RuntimeError if to_fail
        'result'
      end
    end

    subject(:passed) do
      circuit.pass_thru { method.call(false) }
    end

    subject(:failed) do
      circuit.pass_thru { method.call(true) }
    end

    it 'yield block' do
      expect(passed).to eq(method.call)
    end

    it 'keep circuit loaded while failure count less then limit' do
      5.times do |time|
        expect { failed }.to raise_error
        expect(circuit.failure_count).to eq(time + 1)
        expect(circuit.loaded?).to be true
      end
      expect { failed }.to raise_error
      expect(circuit.loaded?).to be false
    end

    it 'raise error if circuit broken' do
      circuit.register_failure(StandardError)
      circuit.break!
      expect { passed }.to raise_error Connfuse::CircuitError
      expect { failed }.to raise_error Connfuse::CircuitError
    end

    it 'yield block again when timeout reached' do
      Timecop.freeze(Time.now)
      circuit.register_failure(StandardError)
      circuit.break!
      expect { passed }.to raise_error Connfuse::CircuitError
      Timecop.travel(Time.now + circuit.timeout)
      expect { passed }.not_to raise_error
      Timecop.return
    end
  end
end
