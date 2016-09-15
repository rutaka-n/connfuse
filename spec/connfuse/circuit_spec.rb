require 'spec_helper'

describe Connfuse::Circuit do
  subject(:circuit) { described_class.new }

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
  end
end
