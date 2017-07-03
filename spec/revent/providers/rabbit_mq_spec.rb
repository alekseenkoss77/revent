require 'spec_helper'

describe Revent::Providers::RabbitMQ do
  describe '#initialize' do
    subject { described_class.new }

    it 'creates mocked connection' do
      expect(subject.conn.class).to eq BunnyMock::Session
      expect(subject.channel.class).to eq BunnyMock::Channel
      expect(subject.queue.class).to eq BunnyMock::Queue
    end
  end

  describe '#publish' do    
    let(:event_name) { 'account.create' }
    
    let!(:event) do
      ActiveSupport::Notifications::Event.new(
        event_name,
        Time.now,
        Time.now,
        SecureRandom.hex(8),
        { foo: :bar }
      )
    end

    subject { described_class.new.publish(event) }

    it 'sends event message to queue' do
      expect(subject.message_count).to eq 1
    end

    it 'sends event payload' do
      message = JSON.parse(subject.pop.last)
      expect(message['event']).to eq event_name
      expect(message['payload']).to eq({ 'foo' => 'bar' })
    end
  end
end
