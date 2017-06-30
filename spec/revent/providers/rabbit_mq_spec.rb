require 'spec_helper'

describe Revent::Providers::RabbitMQ do
  describe 'initialize' do
    subject { described_class.new }

    it 'creates mocked connection' do
      expect(subject.conn.class).to eq BunnyMock::Session
      expect(subject.channel.class).to eq BunnyMock::Channel
      expect(subject.queue.class).to eq BunnyMock::Queue
    end
  end
end
