require 'spec_helper'

describe Revent do
  let(:provider) { :RabbitMQ }

  before do
    Revent.configure do |config|
      config.provider = provider
    end
  end

  describe '.event_provider' do
    subject { Revent.event_provider }

    it 'returns provider class constant' do
      expect(subject).to eq Revent::Providers::RabbitMQ
    end

    context 'bad provider name' do
      let(:provider) { :queue }

      specify { expect(subject).to be_nil }
    end
  end

  describe '.subscribe' do
    let(:event) { 'test.event' }
    subject { Revent.subscribe(event) }

    it 'returns subscribed instance' do
      expect(subject.subscribed_to?(event)).to be_truthy
    end
  end
end
