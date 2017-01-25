require 'revent'
require 'bunny'

module Revent
  module Providers
    class RabbitMQ
      attr_reader :conn, :channel, :queue

      def initialize(connect, channel)
        @connect = connect
        @channel = channel
        @queue = channel.queue('revent_queue', durable: true)
      end

      def publish(event)
        # transform ActiveSupport::Notifications::Event instance to json
        queue.publish(transform_event(event), persistent: true)
      end

      def self.emit(event)
        new(connection, channel).publish(event)
      end

      private

      def transform_event(event)
        return unless event.present?

        {
          event: event.name,
          started: event.time,
          finished: event.end,
          rails_transaction_id: event.transaction_id,
          payload: event.payload
        }.to_json
      end

      def self.connection
        params = {
          hostname: Revent.config.host,
          username: Revent.config.username,
          password: Revent.config.password
        }

        @conn ||= Bunny.new(params).tap do |c|
          c.start
        end
      end

      def self.channel
        @channel ||= connection.create_channel
      end
    end
  end
end
