require 'spec_helper'

describe Revent do
  let(:provider) { :RabbitMQ }

  before do
    described_class.configure do |config|
      config.provider = provider
    end

    described_class.cleanup
  end

  describe '.event_provider' do
    subject { described_class.event_provider }

    it 'returns provider class constant' do
      expect(subject.class).to eq Revent::Providers::RabbitMQ
    end

    context 'bad provider name' do
      let(:provider) { :queue }

      it "responds nil" do
        expect(subject).to be_nil
      end
    end
  end

  describe '.subscribe' do
    let(:event) { 'test.event1' }
    subject { described_class.subscribe(event) }

    it 'returns subscribed instance' do
      expect(subject.subscribed_to?(event)).to be_truthy
    end
  end

  describe '.publish' do
    let(:event) { 'test.event2' }

    before do
      described_class.subscribe(event)
    end

    subject { described_class.publish(event, { foo: :bar }) }

    it 'sends event to queue provider' do
      expect { subject }.to change { described_class.event_provider.queue.message_count }.by(1)
    end

    context 'with many events' do
      subject { 10.times { described_class.publish(event, { foo: :bar }) } }

      specify { expect { subject }.to_not change { described_class.event_provider.object_id } }
      specify { expect { subject }.to_not change { described_class.event_provider.conn.object_id } }
      specify { expect { subject }.to_not change { described_class.event_provider.channel.object_id } }
    end
  end
end
